import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/default_icons.dart';
import 'package:shopping_list_but_free/models/collection.dart';
import 'package:shopping_list_but_free/models/shopping_item.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/objectbox.g.dart';
import 'package:shopping_list_but_free/widgets/add_shopping_item.dart';
import 'package:shopping_list_but_free/widgets/change_collection.dart';
import 'package:shopping_list_but_free/widgets/change_collection_name.dart';
import 'package:shopping_list_but_free/widgets/main_navigation_drawer.dart';

class ShoppingListScreen extends StatefulWidget {
  final int shoppingListId;

  const ShoppingListScreen({
    required this.shoppingListId,
    super.key,
  });

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  /// Relevant Collections to ShoppingList with [widget.shoppingListId] from the previous build
  List<Collection> _prevRelevantCollections = [];
  int _count = 0;

  /// Expansion state of each Collection added to this Widget
  final Map<int, bool> _collectionsExpansionState = {};

  late final Stream<List<ShoppingList>> _shoppingListStream = objectbox
      .shoppingListBox
      .query(ShoppingList_.id.equals(widget.shoppingListId))
      .watch(triggerImmediately: true)
      .map((query) => query.find());

  late final Stream<List<Collection>> _collectionStream = objectbox
      .collectionBox
      .query()
      .watch(triggerImmediately: true)
      .map((query) => query.find());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          objectbox.shoppingListBox.get(widget.shoppingListId) != null
              ? objectbox.shoppingListBox.get(widget.shoppingListId)!.name
              : 'Shopping List',
        ),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              ShoppingList shoppingList = objectbox.shoppingListBox
                  .get(widget.shoppingListId) as ShoppingList;
              if (value == 'delete') {
                // Pop route
                Navigator.of(context).pop();
                // Delete shopping items
                if (shoppingList.shoppingItems.isNotEmpty) {
                  for (var shoppingItem in shoppingList.shoppingItems) {
                    objectbox.shoppingItemBox.remove(shoppingItem.id);
                  }
                }
                // Delete shopping list
                objectbox.shoppingListBox.remove(shoppingList.id);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'export',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Icon(Icons.upload_outlined),
                    Text('Export'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Icon(defaultDeleteIcon),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: const MainNavigationDrawer(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add a new shopping item',
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (_, __, ___) => AddShoppingItem(
                shoppingListId: widget.shoppingListId,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: _collectionStream,
        builder: (context, collectionsSnapshot) {
          if (!collectionsSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return StreamBuilder(
            stream: _shoppingListStream,
            builder: (context, shoppingListSnapshot) {
              // If there is no data
              if (!shoppingListSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // If ShoppingList has been deleted
              if (shoppingListSnapshot.data!.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final ShoppingList shoppingList =
                  shoppingListSnapshot.data!.first;

              /// List of Collections relevant to [shoppingList]
              final List<Collection> relevantCollections = collectionsSnapshot
                  .data!
                  .where((Collection collection) => collection
                      .shoppingItemsNames
                      .any((String shoppingItemName) => shoppingList
                          .shoppingItems
                          .map((ShoppingItem shoppingItem) =>
                              shoppingItem.name.toLowerCase())
                          .contains(shoppingItemName)))
                  .toList();

              // Sort relevantCollections (Others at the end if Others is in the ShoppingList)
              relevantCollections.sort((a, b) {
                return a.name.toLowerCase().compareTo(b.name.toLowerCase());
              });
              if (relevantCollections
                  .any((collection) => collection.name == 'Others')) {
                final int othersIndex = relevantCollections
                    .indexWhere((collection) => collection.name == 'Others');
                Collection others = relevantCollections.removeAt(othersIndex);
                relevantCollections.add(others);
              }

              // Only init _collectionsExpansionState if the Collections in
              // relevantCollections and _collectionsExpansionState are different
              List<int> prevRelevantCollectionsIds = _prevRelevantCollections
                  .map((Collection collection) => collection.id)
                  .toList();
              List<int> relevantCollectionsIds = relevantCollections
                  .map((Collection collection) => collection.id)
                  .toList();
              if (!listEquals(
                  prevRelevantCollectionsIds, relevantCollectionsIds)) {
                for (int id in relevantCollectionsIds) {
                  // only init isExpanded if the Collection is different
                  if (_collectionsExpansionState[id] == null) {
                    _collectionsExpansionState[id] = true;
                  }
                }
              }

              // Generates a new key for ExpansionPanelList if the relevant Collections has changed size
              if (_prevRelevantCollections.length !=
                  relevantCollections.length) {
                _count++;
                _prevRelevantCollections = List.of(relevantCollections);
              }

              return ListView(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  ExpansionPanelList(
                    key: Key('$_count'),
                    expansionCallback: (panelIndex, isExpanded) {
                      final Collection collection =
                          relevantCollections[panelIndex];

                      // Reverse the expansion state of corresponding collection panel
                      setState(() {
                        _collectionsExpansionState[collection.id] =
                            !(_collectionsExpansionState[collection.id]
                                as bool);
                      });
                    },
                    // Relevant collections
                    children: relevantCollections
                        .map(
                          (Collection collection) => ExpansionPanel(
                            canTapOnHeader: true,
                            isExpanded:
                                _collectionsExpansionState[collection.id]
                                    as bool,
                            headerBuilder: (context, isExpanded) {
                              return ListTile(
                                contentPadding: const EdgeInsets.only(left: 20),
                                title: Text(collection.name),
                                trailing: PopupMenuButton(
                                  tooltip: 'Collection options',
                                  onSelected: (value) {
                                    ShoppingList shoppingList = objectbox
                                            .shoppingListBox
                                            .get(widget.shoppingListId)
                                        as ShoppingList;
                                    if (value == 'change name') {
                                      Navigator.of(context).push(
                                        PageRouteBuilder(
                                            opaque: false,
                                            pageBuilder: (_, __, ___) =>
                                                ChangeCollectionName(
                                                    collectionId:
                                                        collection.id)),
                                      );
                                    }
                                    if (value == 'delete') {
                                      // Only ShoppingItems in collection
                                      final List<ShoppingItem> shoppingItems =
                                          shoppingList.shoppingItems
                                              .where((shoppingItem) =>
                                                  collection.shoppingItemsNames
                                                      .contains(shoppingItem
                                                          .name
                                                          .toLowerCase()))
                                              .toList();

                                      // Remove each ShoppingItem from shoppingList
                                      for (ShoppingItem shoppingItem
                                          in shoppingItems) {
                                        shoppingList.shoppingItems.removeWhere(
                                            (si) => si.id == shoppingItem.id);
                                      }

                                      // Update obx
                                      objectbox.shoppingListBox
                                          .put(shoppingList);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'change name',
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: const [
                                          Icon(
                                            Icons.edit,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'Change\nName',
                                            softWrap: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: const [
                                          Icon(
                                            defaultDeleteIcon,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            'Delete',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            body: Column(
                                // Relevant ShoppingItems for each Collection
                                children: shoppingList.shoppingItems
                                    .where((ShoppingItem shoppingItem) =>
                                        collection.shoppingItemsNames.contains(
                                            shoppingItem.name.toLowerCase()))
                                    .map(
                                      (ShoppingItem shoppingItem) =>
                                          Dismissible(
                                        key: ValueKey(shoppingItem.id),
                                        background: Container(
                                          color: Colors.red,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: const [
                                                Icon(defaultDeleteIcon),
                                                Icon(defaultDeleteIcon),
                                              ],
                                            ),
                                          ),
                                        ),
                                        onDismissed:
                                            (DismissDirection direction) {
                                          removeShoppingItem(
                                              shoppingItem, shoppingList);
                                        },
                                        child: Card(
                                          child: ListTile(
                                            leading: Tooltip(
                                              message:
                                                  '${shoppingItem.checked ? 'Uncheck' : 'Check'} shopping item',
                                              child: Checkbox(
                                                onChanged: (value) {
                                                  toggleCheck(shoppingItem,
                                                      shoppingList);
                                                },
                                                value: shoppingItem.checked,
                                              ),
                                            ),
                                            title: Text(
                                              style: shoppingItem.checked
                                                  ? const TextStyle(
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                    )
                                                  : null,
                                              shoppingItem.name,
                                            ),
                                            onTap: () {
                                              toggleCheck(
                                                  shoppingItem, shoppingList);
                                            },
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  tooltip: 'Decrease quantity',
                                                  onPressed: () {
                                                    if (shoppingItem.quantity >
                                                        1) {
                                                      shoppingItem.quantity--;
                                                      objectbox.shoppingItemBox
                                                          .put(shoppingItem);

                                                      objectbox.shoppingListBox
                                                          .put(shoppingList);
                                                    }
                                                  },
                                                  icon: const Icon(
                                                    Icons.remove,
                                                    size: 20,
                                                  ),
                                                ),
                                                Text(
                                                  shoppingItem.quantity
                                                      .toString(),
                                                ),
                                                IconButton(
                                                  tooltip: 'Increase quantity',
                                                  onPressed: () {
                                                    shoppingItem.quantity++;
                                                    objectbox.shoppingItemBox
                                                        .put(shoppingItem);

                                                    objectbox.shoppingListBox
                                                        .put(shoppingList);
                                                  },
                                                  icon: const Icon(
                                                    Icons.add,
                                                    size: 20,
                                                  ),
                                                ),
                                                PopupMenuButton(
                                                  tooltip:
                                                      'Shopping item options',
                                                  onSelected: (value) {
                                                    if (value == 'delete') {
                                                      removeShoppingItem(
                                                          shoppingItem,
                                                          shoppingList);
                                                    }

                                                    if (value ==
                                                        'change collection') {
                                                      Navigator.of(context)
                                                          .push(
                                                        PageRouteBuilder(
                                                          opaque: false,
                                                          barrierColor: Colors
                                                              .black
                                                              .withOpacity(0.5),
                                                          barrierDismissible:
                                                              true,
                                                          pageBuilder: (_, __,
                                                                  ___) =>
                                                              ChangeCollection(
                                                            shoppingItem:
                                                                shoppingItem,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  itemBuilder: (context) => [
                                                    PopupMenuItem(
                                                      value:
                                                          'change collection',
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: const [
                                                          Icon(
                                                            Icons.edit,
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            'Change\nCollection',
                                                            softWrap: true,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 'delete',
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: const [
                                                          Icon(
                                                            defaultDeleteIcon,
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            'Delete',
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList()),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 10,
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }

  /// Deletes shoppingItem and causes StreamBuilder to rebuild
  void removeShoppingItem(
      ShoppingItem shoppingItem, ShoppingList shoppingList) {
    // Remove shopping item from shopping list
    shoppingList.shoppingItems.remove(shoppingItem);
    // Put new shopping list in obx
    objectbox.shoppingListBox.put(shoppingList);
    // Remove shopping item form obx
    objectbox.shoppingItemBox.remove(shoppingItem.id);
  }

  /// Checks or unchecks shoppingItems
  void toggleCheck(ShoppingItem shoppingItem, ShoppingList shoppingList) {
    // Allows ObjectBox to update shoppingItem with the same ID
    shoppingItem.checked = !shoppingItem.checked;
    objectbox.shoppingItemBox.put(shoppingItem);

    // Forces StreamBuilder to rebuild since it depends on a ShoppingList Stream
    objectbox.shoppingListBox.put(shoppingList);
  }
}
