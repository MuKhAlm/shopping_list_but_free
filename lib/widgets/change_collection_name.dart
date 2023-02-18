import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/models/collection.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/widgets/add_entity.dart';

/// Displays a form that renames given [collection] across entire app
class ChangeCollectionName extends StatefulWidget {
  final int collectionId;

  const ChangeCollectionName({
    required this.collectionId,
    Key? key,
  }) : super(key: key);

  @override
  State<ChangeCollectionName> createState() => _ChangeCollectionNameState();
}

class _ChangeCollectionNameState extends State<ChangeCollectionName> {
  @override
  Widget build(BuildContext context) {
    return AddEntity(
      onSubmit: _submit,
      inputFieldHintText: 'New name',
    );
  }

  void _submit(String newCollectionName) {
    final Collection collection =
        objectbox.collectionBox.get(widget.collectionId) as Collection;
    collection.name = newCollectionName.trim();
    objectbox.collectionBox.put(collection);
    Navigator.of(context).pop();
  }
}
