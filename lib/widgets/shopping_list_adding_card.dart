import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';
import 'package:shopping_list_but_free/objectbox.dart';

/// Creates a card to add shopping lists
class ShoppingListAddingCard extends StatefulWidget {
  final Function onBack;

  const ShoppingListAddingCard({
    required this.onBack,
    super.key,
  });

  @override
  State<ShoppingListAddingCard> createState() => _ShoppingListAddingCardState();
}

class _ShoppingListAddingCardState extends State<ShoppingListAddingCard> {
  String _shoppingListName = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(0, 0, 0, 0.5),
      child: Center(
        child: SizedBox(
          width: min(MediaQuery.of(context).size.width - 10, 300),
          height: 200,
          child: Card(
            elevation: 20,
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      onPressed: () {
                        widget.onBack();
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Form(
                    child: Column(
                      children: [
                        TextFormField(
                          autofocus: true,
                          initialValue: _shoppingListName,
                          decoration: const InputDecoration(
                            hintText: 'Shopping List Name',
                          ),
                          onChanged: (value) {
                            setState(() {
                              _shoppingListName = value;
                            });
                          },
                          onFieldSubmitted: (value) {
                            _submit();
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: IconButton(
                            tooltip: 'Add shopping list',
                            onPressed: (() {
                              _submit();
                            }),
                            icon: Icon(
                              Icons.add_circle_rounded,
                              color: Theme.of(context).primaryColor,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Adds a new [ShoppingList] with the name value of [_shoppingListName],
  /// and removes the card.
  ///
  /// if [_shoppingListName] is empty, name value will be **Undefined**
  void _submit() {
    String name = 'Untitled';
    if (_shoppingListName != '') {
      name = _shoppingListName;
    }

    objectbox.shoppingListBox.put(ShoppingList(name: name));
    widget.onBack();
  }
}
