import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/models/collection.dart';
import 'package:shopping_list_but_free/models/shopping_item.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/objectbox.g.dart';
import 'package:shopping_list_but_free/widgets/add_entity.dart';

/// Displays a form that creates a new **Collection** and stores it to obx when submitted.
///
/// If a [shoppingItem] is given, it adds its **name (all lower case)**  to **Collection**.
class AddCollection extends StatefulWidget {
  final ShoppingItem? shoppingItem;

  const AddCollection({
    this.shoppingItem,
    Key? key,
  }) : super(key: key);

  @override
  State<AddCollection> createState() => _AddCollectionState();
}

class _AddCollectionState extends State<AddCollection> {
  @override
  Widget build(BuildContext context) {
    return AddEntity(
      onSubmit: _submit,
      inputFieldHintText: 'Collection name',
    );
  }

  void _submit(String collectionName) {
    final Collection newCollection = Collection(name: collectionName.trim());

    // Add shoppingItem's name to collection if a shoppingItem is provided
    if (widget.shoppingItem != null) {
      final currentCollection = objectbox.collectionBox
          .query(Collection_.shoppingItemsNames
              .containsElement(widget.shoppingItem!.name.toLowerCase()))
          .build()
          .findFirst();

      // Remove shoppingItem name from current Collection that
      // has it
      currentCollection!.shoppingItemsNames
          .remove(widget.shoppingItem!.name.toLowerCase());

      // Add Collection to objectbox
      objectbox.collectionBox.put(currentCollection);

      // Add shoppingItem name to new Collection
      newCollection.shoppingItemsNames
          .add(widget.shoppingItem!.name.toLowerCase());
    }

    // Add newCollection to obx
    objectbox.collectionBox.put(newCollection);

    // Pop Widget
    Navigator.of(context).pop();
  }
}
