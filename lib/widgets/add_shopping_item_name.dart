import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/models/collection.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/widgets/add_entity.dart';

/// Displays a form that creates a new **ShoppingList** and stores it to obx when submitted.
class AddShoppingItemName extends StatefulWidget {
  final int collectionId;
  const AddShoppingItemName({
    required this.collectionId,
    Key? key,
  }) : super(key: key);

  @override
  State<AddShoppingItemName> createState() => _AddShoppingItemNameState();
}

class _AddShoppingItemNameState extends State<AddShoppingItemName> {
  @override
  Widget build(BuildContext context) {
    return AddEntity(
      onSubmit: _submit,
      inputFieldHintText: 'New shopping item name',
    );
  }

  void _submit(String newShoppingItemName) {
    Collection collection =
        objectbox.collectionBox.get(widget.collectionId) as Collection;
    collection.shoppingItemsNames.add(newShoppingItemName.trim().toLowerCase());

    objectbox.collectionBox.put(collection);

    Navigator.of(context).pop();
  }
}
