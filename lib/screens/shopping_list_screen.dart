import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shoppingList.name),
      ),
      drawer: const Drawer(),
      body: const SafeArea(
        child: Placeholder(),
      ),
    );
  }
}
