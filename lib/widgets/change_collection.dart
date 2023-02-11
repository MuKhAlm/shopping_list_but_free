import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/models/collection.dart';
import 'package:shopping_list_but_free/models/shopping_item.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/objectbox.g.dart';
import 'package:shopping_list_but_free/widgets/add_collection.dart';

/// Displays a **card** containing a **form**,
///
/// Selects a already-existing or new **Collection** for [shoppingItem],
///
/// Changes corresponding collection for all ShoppingItem with the same name as [shoppingItem]
/// (**NOT CASE SENSITIVE**) across the app.
class ChangeCollection extends StatefulWidget {
  final ShoppingItem shoppingItem;

  const ChangeCollection({
    required this.shoppingItem,
    super.key,
  });

  @override
  State<ChangeCollection> createState() => _ChangeCollectionState();
}

class _ChangeCollectionState extends State<ChangeCollection> {
  late Collection _selectedCollection;
  List<Collection> collections = objectbox.collectionBox.getAll();

  @override
  void initState() {
    super.initState();
    // Picks an initial collection
    setState(() {
      _selectedCollection = collections[0];
    });
  }

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
              // Forces Padding to take all available space
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Form(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<Collection>(
                                isExpanded: true,
                                value: _selectedCollection,
                                items: collections
                                    .map(
                                      (collection) => DropdownMenuItem(
                                        value: collection,
                                        child: Text(collection.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedCollection = value;
                                    });
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              tooltip: 'Add to a new collection',
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  PageRouteBuilder(
                                    opaque: false,
                                    pageBuilder: (_, __, ___) => AddCollection(
                                      shoppingItem: widget.shoppingItem,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                        IconButton(
                          tooltip: 'Submit',
                          onPressed: () {
                            final String shoppingItemName =
                                widget.shoppingItem.name.toLowerCase();
                            final Collection currentCollection = objectbox
                                .collectionBox
                                .query(Collection_.shoppingItemsNames
                                    .containsElement(shoppingItemName))
                                .build()
                                .findFirst() as Collection;
                            final Collection newCollection =
                                _selectedCollection;

                            // Remove shoppingItem name from current Collection that
                            // has it
                            currentCollection.shoppingItemsNames
                                .remove(shoppingItemName);
                            // Add shoppingItem name to selected Collection
                            newCollection.shoppingItemsNames
                                .add(shoppingItemName);

                            // Put both Collections in obx to rebuild UI
                            objectbox.collectionBox
                                .putMany([currentCollection, newCollection]);

                            // Pop Widget
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.done),
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
}
