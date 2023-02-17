import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/models/collection.dart';
import 'package:shopping_list_but_free/models/shopping_item.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/objectbox.g.dart';
import 'package:shopping_list_but_free/widgets/main_navigation_drawer.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({Key? key}) : super(key: key);

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  /// Collections from the previous build
  List<Collection> _prevCollections = [];
  int _count = 0;

  /// Expansion state of each Collection added to this Widget
  final Map<int, bool> _collectionsExpansionState = {};

  late final Stream<List<Collection>> _collectionStream = objectbox
      .collectionBox
      .query()
      .watch(triggerImmediately: true)
      .map((query) => query.find());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
      ),
      drawer: const MainNavigationDrawer(),
      body: StreamBuilder(
        stream: _collectionStream,
        builder: (context, collectionsSnapshot) {
          if (!collectionsSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final List<Collection> collections =
              collectionsSnapshot.data as List<Collection>;

          // Only init _collectionsExpansionState if the Collections in
          // relevantCollections and _collectionsExpansionState are different
          List<int> prevCollectionsIds = _prevCollections
              .map((Collection collection) => collection.id)
              .toList();
          List<int> collectionsIds = collections
              .map((Collection collection) => collection.id)
              .toList();
          if (!listEquals(prevCollectionsIds, collectionsIds)) {
            for (int id in collectionsIds) {
              // only init isExpanded if the Collection is different
              if (_collectionsExpansionState[id] == null) {
                _collectionsExpansionState[id] = true;
              }
            }
          }

          // Generates a new key for ExpansionPanelList if the relevant Collections has changed size
          if (_prevCollections.length != collections.length) {
            _count++;
            _prevCollections = List.of(collections);
          }

          return ListView(
            children: [
              ExpansionPanelList(
                key: Key('$_count'),
                expansionCallback: (panelIndex, isExpanded) {
                  final Collection collection = collections[panelIndex];

                  // Reverse the expansion state of corresponding collection panel
                  setState(() {
                    _collectionsExpansionState[collection.id] =
                        !(_collectionsExpansionState[collection.id] as bool);
                  });
                },
                children: collections.map((Collection collection) {
                  return ExpansionPanel(
                    canTapOnHeader: true,
                    isExpanded:
                        _collectionsExpansionState[collection.id] as bool,
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                        title: Text(collection.name),
                      );
                    },
                    body: Column(
                      children: collection.shoppingItemsNames
                          .map((String shoppingItemName) {
                        return ListTile(
                          title: Text(shoppingItemName),
                          trailing: IconButton(
                            tooltip:
                                'Remove shopping item name from collection',
                            onPressed: () {
                              // Delete shoppingItemName from collection and move it to Others
                              // if there are ShoppingItem with given name
                              // This is because some ShoppingLists might still
                              // contain a ShoppingItem with the given name
                              collection.shoppingItemsNames
                                  .remove(shoppingItemName);

                              ShoppingItem;

                              List<ShoppingList> shoppingLists =
                                  objectbox.shoppingListBox.getAll();
                              if (shoppingLists.any(
                                  (ShoppingList shoppingList) => shoppingList
                                      .shoppingItems
                                      .map((ShoppingItem shoppingItem) =>
                                          shoppingItem.name.toLowerCase())
                                      .contains(shoppingItemName))) {
                                Collection others = objectbox.collectionBox
                                    .query(Collection_.name.equals('Others'))
                                    .build()
                                    .findFirst() as Collection;
                                others.shoppingItemsNames.add(shoppingItemName);
                                objectbox.collectionBox.put(others);
                              }

                              objectbox.collectionBox.put(collection);
                            },
                            icon: const Icon(Icons.delete_forever_outlined),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height / 10,
              ),
            ],
          );
        },
      ),
    );
  }
}
