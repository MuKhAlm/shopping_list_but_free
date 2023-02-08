import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/models/collection.dart';
import 'package:shopping_list_but_free/models/shopping_item.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/objectbox.g.dart';

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
  String _collectionName = '';

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
                            hintText: 'Collection name',
                          ),
                          initialValue: _collectionName,
                          onChanged: (value) {
                            setState(() {
                              _collectionName = value;
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
    final Collection newCollection = Collection(name: _collectionName);

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
