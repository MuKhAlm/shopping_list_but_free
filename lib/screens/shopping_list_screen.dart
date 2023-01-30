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
                // Delete shopping items
                if (_shoppingList.shoppingItems.isNotEmpty) {
                  for (var shoppingItem in _shoppingList.shoppingItems) {
                    objectbox.shoppingItemBox.remove(shoppingItem.id);
                  }
                }
                // Delete shopping list
                objectbox.shoppingListBox.remove(_shoppingList.id);
                // Pop route
                Navigator.of(context).pop();
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
              if (!shoppingListSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return Column(
                children: [
                  ExpansionPanelList(
                    expansionCallback: (panelIndex, isExpanded) {
                      collectionsSnapshot.data![panelIndex].expanded =
                          !isExpanded;
                      setState(() {
                        _expanded[panelIndex] = !isExpanded;
                      });
                    },
                    children: collectionsSnapshot.data!
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
                            body: const Text('Shopping Items'),
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
