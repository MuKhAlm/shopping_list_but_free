import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/screens/home_screen.dart';

void main() async {
  objectbox = await ObjectBox.open();
  group('HomeScreen', () {
    group('static', () {
      testWidgets('Display navigation menu', (tester) async {
        await tester.pumpWidget(getHomeScreen());
        expect(find.byTooltip('Open navigation menu'), findsOneWidget);
      });

      testWidgets('Dispaly shopping list adding button', (tester) async {
        await tester.pumpWidget(getHomeScreen());
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('Display correct title', (tester) async {
        // Empty obx
        objectbox.shoppingListBox.removeAll();
        // Add 20 ShoppingLists
        for (var i = 1; i <= 20; i++) {
          objectbox.shoppingListBox.put(ShoppingList(name: 'Shopping List $i'));
        }
        expect(objectbox.shoppingListBox.getAll().length, 20);

        await tester.pumpWidget(getHomeScreen());
        expect(find.text('Shopping List But Free'), findsOneWidget);
      });
    });
  });
}

Widget getHomeScreen() {
  return const MaterialApp(
    home: HomeScreen(),
  );
}
