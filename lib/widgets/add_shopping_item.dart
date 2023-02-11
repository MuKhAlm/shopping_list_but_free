import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/models/collection.dart';
import 'package:shopping_list_but_free/models/shopping_item.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/objectbox.g.dart';
import 'package:shopping_list_but_free/widgets/add_entity.dart';

/// Displays a form that creates a new **ShoppingItem** and stores it to obx when submitted.
///
/// If the **ShoppingItem**'s name is not an a Collection, add the **ShoppingItem**'s name
/// to the **Others** Collection.
class AddShoppingItem extends StatefulWidget {
  final int shoppingListId;
  const AddShoppingItem({
    required this.shoppingListId,
    Key? key,
  }) : super(key: key);

  @override
  State<AddShoppingItem> createState() => _AddShoppingItemState();
}

class _AddShoppingItemState extends State<AddShoppingItem> {
  @override
  Widget build(BuildContext context) {
    return AddEntity(
      onSubmit: _submit,
      inputFieldHintText: 'Shopping item name',
    );
  }

  /// Adds a ** ShoppingItem** with the name [newShoppingItemName] to a ShoppingList
  /// with [shoppingListId].
  ///
  /// If the **ShoppingItem**'s name is not an a Collection, add the **ShoppingItem**'s name
  /// to the **Others** Collection.
  void _submit(String newShoppingItemName) {
    final String name;
    if (newShoppingItemName != '') {
      name = newShoppingItemName;
    } else {
      name = 'Untitled';
    }

    // Create ShoppingItem
    final ShoppingItem shoppingItem = ShoppingItem(name: name);

    // Add to ShoppingList
    final ShoppingList shoppingList =
        objectbox.shoppingListBox.get(widget.shoppingListId) as ShoppingList;
    shoppingList.shoppingItems.add(shoppingItem);

    // Put ShoppingList in obx
    objectbox.shoppingListBox.put(shoppingList);

    // If shoppingItem's name is not already in a collection
    final Query<Collection> collectionsQuery = objectbox.collectionBox
        .query(Collection_.shoppingItemsNames
            .containsElement(shoppingItem.name.toLowerCase()))
        .build();
    if (collectionsQuery.count() == 0) {
      // Check if Others Collection is created
      Query<Collection> othersQuery = objectbox.collectionBox
          .query(Collection_.name.equals('Others'))
          .build();
      final Collection others;
      if (othersQuery.count() == 0) {
        // Create Others Collection
        others = Collection(name: 'Others');
      } else {
        others = othersQuery.findFirst() as Collection;
      }

      // Add shoppingItem to others
      others.shoppingItemsNames.add(shoppingItem.name.toLowerCase());
      // Put others in obx
      objectbox.collectionBox.put(others);
    }

    // Pop Widget
    Navigator.of(context).pop();
  }
}
