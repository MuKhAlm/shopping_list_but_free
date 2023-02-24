import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';

/// Displays a card that lets the user copy the Json encoding of
/// [shoppingList]
class ExportShoppingList extends StatelessWidget {
  final ShoppingList shoppingList;
  const ExportShoppingList({
    required this.shoppingList,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          Center(
            child: SizedBox(
              width: min(MediaQuery.of(context).size.width - 10, 300),
              height: MediaQuery.of(context).size.height / 3,
              child: Card(
                elevation: 20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Expanded(
                      flex: 0,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Share the shopping list code for others to import it',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Copied shopping list code to clipboard'),
                              ),
                            );

                            await Clipboard.setData(
                              ClipboardData(
                                  text: json.encode(shoppingList.toJson())),
                            );
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('Shopping list code'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
