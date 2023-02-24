import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/models/collection.dart';
import 'package:shopping_list_but_free/models/shopping_item.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/objectbox.g.dart';
import 'package:shopping_list_but_free/screens/shopping_list_screen.dart';

/// Displays a card that lets the user copy the Json encoding of
/// [shoppingList]
class ImportShoppingList extends StatefulWidget {
  const ImportShoppingList({
    Key? key,
  }) : super(key: key);

  @override
  State<ImportShoppingList> createState() => _ImportShoppingListState();
}

/// Import a ShoppingList by creating a new ShoppingList from given
/// shopping list json.
class _ImportShoppingListState extends State<ImportShoppingList> {
  String shoppingListJson = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          Center(
            child: SizedBox(
              width: min(MediaQuery.of(context).size.width - 10, 300),
              height: MediaQuery.of(context).size.height / 3,
              child: Card(
                elevation: 20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      flex: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: TextField(
                          autocorrect: false,
                          decoration: const InputDecoration(
                            hintText: 'Enter shopping list code',
                          ),
                          onChanged: (String value) {
                            setState(() {
                              shoppingListJson = value.trim();
                            });
                          },
                          onSubmitted: (value) {
                            _import();
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Import',
                      onPressed: () {
                        _import();
                      },
                      icon: const Icon(Icons.download_outlined),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _import() {
    final shoppingListMap = json.decode(shoppingListJson);

    final shoppingList = ShoppingList(name: shoppingListMap['name']);

    for (var shoppingItemMap in shoppingListMap['shoppingItems']) {
      // Create ShoppingItem
      final shoppingItem = ShoppingItem(name: shoppingItemMap['name']);
      shoppingItem.checked = shoppingItemMap['checked'];
      shoppingItem.quantity = shoppingItemMap['quantity'];

      // Add shoppingItem to the others Collection if is not in any other Collection
      if (!objectbox.collectionBox.getAll().any((collection) => collection
          .shoppingItemsNames
          .contains(shoppingItem.name.toLowerCase()))) {
        final others = objectbox.collectionBox
            .query(Collection_.name.equals('Others'))
            .build()
            .findFirst() as Collection;

        others.shoppingItemsNames.add(shoppingItem.name.toLowerCase());

        objectbox.collectionBox.put(others);
      }

      shoppingList.shoppingItems.add(shoppingItem);
    }

    objectbox.shoppingListBox.put(shoppingList);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            ShoppingListScreen(shoppingListId: shoppingList.id),
      ),
    );
  }
}
