import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';
import 'package:shopping_list_but_free/objectbox.dart';

class ShoppingListScreen extends StatefulWidget {
  final ShoppingList shoppingList;

  const ShoppingListScreen({
    required this.shoppingList,
    super.key,
  });

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  @override
  Widget build(BuildContext context) {
    var shoppingList = widget.shoppingList;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shoppingList.name),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'delete') {
                // Delete shopping items
                if (shoppingList.shoppingItems.isNotEmpty) {
                  for (var shoppingItem in shoppingList.shoppingItems) {
                    objectbox.shoppingItemBox.remove(shoppingItem.id);
                  }
                }
                // Delete shopping list
                objectbox.shoppingListBox.remove(shoppingList.id);
                // Pop route
                Navigator.of(context).pop();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Icon(Icons.delete_forever_outlined),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: const Drawer(),
      body: const SafeArea(
        child: Placeholder(),
      ),
    );
  }
}
