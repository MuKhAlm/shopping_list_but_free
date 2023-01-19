import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/objectbox.g.dart';
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

    group('Dynamic', () {
      testWidgets('Remove shopping lists correctly', (tester) async {
        // Setup
        objectbox.shoppingListBox.removeAll();
        expect(objectbox.shoppingListBox.getAll().length, 0);
        addShoppingLists(objectbox, 3);
        expect(objectbox.shoppingListBox.getAll().length, 3);
        await tester.pumpWidget(getHomeScreen());
        await tester.pumpAndSettle();

        // Removing second item
        await tester.tap(find.byIcon(Icons.remove_circle_sharp).at(1));
        await tester.pumpAndSettle();

        expect(find.text('Shopping List 2'), findsNothing);
        expect(objectbox.shoppingListBox.getAll().length, 2);
      });

      group('Shopping List addition', () {
        testWidgets(
            'Display shopping list addition card when floating action button is pressed',
            (tester) async {
          await setUp(tester, 1);

          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();

          expect(find.byType(Form), findsOneWidget);
        });

        testWidgets(
            'Add shopping list when Add button is pressed in shopping list addition form',
            (tester) async {
          await setUp(tester, 1);

          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();

          expect(find.byType(Form), findsOneWidget);

          await tester.enterText(
              find.byType(TextFormField), 'New Shopping List');
          await tester.pumpAndSettle();
          await tester.tap(find.byTooltip('Add shopping list'));
          await tester.pumpAndSettle();

          expect(find.text('New Shopping List'), findsOneWidget);
          expect(
              objectbox.shoppingListBox
                  .query(ShoppingList_.name.equals('New Shopping List'))
                  .build()
                  .find()
                  .length,
              1);
        });
      });
    });
  });
}

Future<void> setUp(WidgetTester tester, int numberOfShoppingLists) async {
  objectbox.shoppingListBox.removeAll();
  expect(objectbox.shoppingListBox.getAll().length, 0);
  addShoppingLists(objectbox, numberOfShoppingLists);
  expect(objectbox.shoppingListBox.getAll().length, numberOfShoppingLists);
  await tester.pumpWidget(getHomeScreen());
  await tester.pumpAndSettle();
}

/// Adds [ShoppingList]s to [objectbox], [n] times
///
/// [ShoppingList]s are named from 'Shopping List 1' to 'Shopping List n'
void addShoppingLists(ObjectBox objectbox, int n) {
  for (var i = 1; i <= n; i++) {
    objectbox.shoppingListBox.put(ShoppingList(name: 'Shopping List $i'));
  }
}

Widget getHomeScreen() {
  return const MaterialApp(
    home: HomeScreen(),
  );
}
