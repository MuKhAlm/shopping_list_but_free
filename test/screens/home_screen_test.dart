import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/screens/home_screen.dart';
import 'package:shopping_list_but_free/screens/shopping_list_screen.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
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

        // Remove first item
        await tester.tap(find.byTooltip('Remove shopping list').first);
        await tester.pumpAndSettle();

        await tester.runAsync(
          () async {
            await Future.delayed(const Duration(seconds: 1));

            await tester.pumpAndSettle();

            // Test for absence of Shopping List 1
            expect(find.text('Shopping List 1'), findsNothing);
          },
        );
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
      });

      testWidgets(
          'Navigates to a shopping list screen when a shopping list is pressed',
          (tester) async {
        await setUp(tester, 1);

        // Tap on shopping list
        await tester.tap(find.text('Shopping List 1'));
        await tester.pumpAndSettle();

        // check if Shopping List Screen exists
        expect(find.byType(ShoppingListScreen), findsOneWidget);
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
  return MaterialApp(
    home: HomeScreen(),
  );
}

class FakePathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '.';
  }
}
