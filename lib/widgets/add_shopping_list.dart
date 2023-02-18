import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/widgets/add_entity.dart';

/// Displays a form that creates a new **ShoppingList** and stores it to obx when submitted.
class AddShoppingList extends StatefulWidget {
  const AddShoppingList({Key? key}) : super(key: key);

  @override
  State<AddShoppingList> createState() => _AddShoppingListState();
}

class _AddShoppingListState extends State<AddShoppingList> {
  @override
  Widget build(BuildContext context) {
    return AddEntity(
      onSubmit: _submit,
      inputFieldHintText: 'Shopping list name',
    );
  }

  /// Creates a new **ShoppingList** with the name [newShoppingListName] and puts
  /// it in obx.
  ///
  /// Trims [newShoppingListName] before creating the **ShoppingList**
  void _submit(String newShoppingListName) {
    objectbox.shoppingListBox
        .put(ShoppingList(name: newShoppingListName.trim()));
    Navigator.of(context).pop();
  }
}
