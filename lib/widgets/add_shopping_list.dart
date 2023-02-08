import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';
import 'package:shopping_list_but_free/objectbox.dart';

/// Displays a form that creates a new **ShoppingList** and stores it to obx when submitted.
class AddShoppingList extends StatefulWidget {
  const AddShoppingList({Key? key}) : super(key: key);

  @override
  State<AddShoppingList> createState() => _AddShoppingListState();
}

class _AddShoppingListState extends State<AddShoppingList> {
  String _newShoppingListName = '';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: min(MediaQuery.of(context).size.width - 10, 300),
        height: MediaQuery.of(context).size.height / 3,
        child: Card(
          elevation: 20,
          child: Column(
            children: [
              Row(
                children: [
                  BackButton(
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Form(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextFormField(
                          autofocus: true,
                          decoration: const InputDecoration(
                            hintText: 'Shopping list name',
                          ),
                          initialValue: _newShoppingListName,
                          onChanged: (value) {
                            setState(() {
                              _newShoppingListName = value;
                            });
                          },
                          onFieldSubmitted: (value) {
                            _submit();
                          },
                        ),
                        IconButton(
                          tooltip: 'Submit',
                          onPressed: (() {
                            _submit();
                          }),
                          icon: const Icon(
                            Icons.done,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    String name = 'Untitled';
    if (_newShoppingListName != '') {
      name = _newShoppingListName;
    }

    objectbox.shoppingListBox.put(ShoppingList(name: name));
    Navigator.of(context).pop();
  }
}
