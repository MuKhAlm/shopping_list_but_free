import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/models/collection.dart';
import 'package:shopping_list_but_free/models/shopping_item.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/objectbox.g.dart';
import 'package:shopping_list_but_free/widgets/add_shopping_item.dart';
import 'package:shopping_list_but_free/widgets/change_collection.dart';

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

  /// Keeps track of expanded and collapsed [Collection]s
  List<bool> _expanded = [];

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
                value: 'delete',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Icon(Icons.delete_forever_outlined),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: const Drawer(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add a new shopping item',
        onPressed: () {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              barrierColor: Colors.black.withOpacity(0.5),
              barrierDismissible: true,
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

          _expanded = collectionsSnapshot.data!
              .map(
                (Collection collection) => collection.expanded,
              )
              .toList();
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

              // Generates a new key for ExpansionPanelList if the relevant Collections has changed size
              if (_prevRelevantCollections.length !=
                  relevantCollections.length) {
                _count++;
                _prevRelevantCollections = List.of(relevantCollections);
              }

              return ListView(
                children: [
                  ExpansionPanelList(
                    expansionCallback: (panelIndex, isExpanded) {
                      collectionsSnapshot.data![panelIndex].expanded =
                          !isExpanded;
                      setState(() {
                        _expanded[panelIndex] = !isExpanded;
                      });
                    },
                    // Relevant collections
                    children: relevantCollections
                        .map(
                          (Collection collection) => ExpansionPanel(
                            canTapOnHeader: true,
                            isExpanded: _expanded[
                                collectionsSnapshot.data!.indexOf(collection)],
                            headerBuilder: (context, isExpanded) {
                              return ListTile(
                                title: Text(collection.name),
                              );
                            },
                            body: Column(
                              // Relevant ShoppingItems for each Collection
                              children: shoppingList.shoppingItems
                                  .where((ShoppingItem shoppingItem) =>
                                      collection.shoppingItemsNames.contains(
                                          shoppingItem.name.toLowerCase()))
                                  .map(
                                    (ShoppingItem shoppingItem) => ListTile(
                                      leading: Tooltip(
                                        message:
                                            '${shoppingItem.checked ? 'Uncheck' : 'Check'} shopping item',
                                        child: Checkbox(
                                          onChanged: (value) {
                                            toggleCheck(
                                                shoppingItem, shoppingList);
                                          },
                                          value: shoppingItem.checked,
                                        ),
                                      ),
                                      title: Text(
                                        style: shoppingItem.checked
                                            ? const TextStyle(
                                                decoration:
                                                    TextDecoration.lineThrough,
                                              )
                                            : null,
                                        shoppingItem.name,
                                      ),
                                      onTap: () {
                                        toggleCheck(shoppingItem, shoppingList);
                                      },
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            tooltip: 'Increase quantity',
                                            onPressed: () {
                                              shoppingItem.quantity++;
                                              objectbox.shoppingItemBox
                                                  .put(shoppingItem);

                                              objectbox.shoppingListBox
                                                  .put(shoppingList);
                                            },
                                            icon: const Icon(Icons.add),
                                          ),
                                          Text(
                                            shoppingItem.quantity.toString(),
                                          ),
                                          IconButton(
                                            tooltip: 'Decrease quantity',
                                            onPressed: () {
                                              if (shoppingItem.quantity > 1) {
                                                shoppingItem.quantity--;
                                                objectbox.shoppingItemBox
                                                    .put(shoppingItem);

                                                objectbox.shoppingListBox
                                                    .put(shoppingList);
                                              }
                                            },
                                            icon: const Icon(Icons.remove),
                                          ),
                                          PopupMenuButton(
                                            tooltip: 'Shopping item options',
                                            onSelected: (value) {
                                              if (value == 'delete') {
                                                // Remove shopping item from shopping list
                                                shoppingList.shoppingItems
                                                    .remove(shoppingItem);
                                                // Put new shopping list in obx
                                                objectbox.shoppingListBox
                                                    .put(shoppingList);
                                                // Remove shopping item form obx
                                                objectbox.shoppingItemBox
                                                    .remove(shoppingItem.id);
                                              }

                                              if (value ==
                                                  'change collection') {
                                                Navigator.of(context).push(
                                                  PageRouteBuilder(
                                                    opaque: false,
                                                    barrierColor: Colors.black
                                                        .withOpacity(0.5),
                                                    barrierDismissible: true,
                                                    pageBuilder: (_, __, ___) =>
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
                                                value: 'change collection',
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
                                                      MainAxisAlignment.start,
                                                  children: const [
                                                    Icon(
                                                      Icons
                                                          .delete_forever_outlined,
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
                                  )
                                  .toList(),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
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
