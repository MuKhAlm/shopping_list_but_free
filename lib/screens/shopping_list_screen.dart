import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/models/collection.dart';
import 'package:shopping_list_but_free/models/shopping_item.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/objectbox.g.dart';

class ShoppingListScreen extends StatefulWidget {
  final ShoppingList shoppingList;

  const ShoppingListScreen({
    required this.shoppingList,
    super.key,
  });

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  late final _shoppingList = widget.shoppingList;

  late final Stream<List<ShoppingList>> _shoppingListStream = objectbox
      .shoppingListBox
      .query(ShoppingList_.id.equals(_shoppingList.id))
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
        title: Text(widget.shoppingList.name),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'delete') {
                // Pop route
                Navigator.of(context).pop();
                // Delete shopping items
                if (_shoppingList.shoppingItems.isNotEmpty) {
                  for (var shoppingItem in _shoppingList.shoppingItems) {
                    objectbox.shoppingItemBox.remove(shoppingItem.id);
                  }
                }
                // Delete shopping list
                objectbox.shoppingListBox.remove(_shoppingList.id);
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
                    children: collectionsSnapshot.data!
                        .where((Collection collection) => collection
                            .shoppingItemsNames
                            .any((String shoppingItemName) =>
                                shoppingListSnapshot.data![0].shoppingItems
                                    .map((ShoppingItem shoppingItem) =>
                                        shoppingItem.name.toLowerCase())
                                    .contains(shoppingItemName)))
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
                              children: shoppingListSnapshot
                                  .data![0].shoppingItems
                                  .where((ShoppingItem shoppingItem) =>
                                      collection.shoppingItemsNames.contains(
                                          shoppingItem.name.toLowerCase()))
                                  .map(
                                    (ShoppingItem shoppingItem) =>
                                        Text(shoppingItem.name),
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
}
