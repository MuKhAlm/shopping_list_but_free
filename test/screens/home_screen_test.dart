import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/screens/home_screen.dart';
import 'package:shopping_list_but_free/screens/shopping_list_screen.dart';
import 'package:shopping_list_but_free/widgets/add_shopping_list.dart';

void main() async {
  // Initialize objectbox
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  objectbox = await ObjectBox.open();

  /// Empties database and populates it
  void dbSetUp([Function? populate]) {
    // Empty database
    objectbox.shoppingListBox.removeAll();
    objectbox.shoppingItemBox.removeAll();
    objectbox.collectionBox.removeAll();

    if (populate != null) {
      // Populate database
      populate();
    }
  }

  Widget getHomeScreen() => MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: HomeScreen(),
      );

  group(
    'HomeScreen',
    () {
      group(
        'AppBar',
        () {
          testWidgets(
            'Displays nav menu',
            (tester) async {
              // Setup
              dbSetUp();

              await tester.pumpWidget(getHomeScreen());
              await tester.pumpAndSettle();

              // Test for nav menu
              expect(find.byTooltip('Open navigation menu'), findsOneWidget);
            },
          );

          testWidgets(
            'Display title',
            (tester) async {
              // Setup
              dbSetUp();

              await tester.pumpWidget(getHomeScreen());
              await tester.pumpAndSettle();

              // Test for title
              expect(find.text('Shopping List But Free'), findsOneWidget);
            },
          );
        },
      );

      group(
        'Shopping lists',
        () {
          testWidgets(
            'Names displayed',
            (tester) async {
              // Setup
              final ShoppingList testShoppingList1 =
                  ShoppingList(name: 'Test Shopping List 1');
              final ShoppingList testShoppingList2 =
                  ShoppingList(name: 'Test Shopping List 2');
              final ShoppingList testShoppingList3 =
                  ShoppingList(name: 'Test Shopping List 3');

              dbSetUp(() {
                objectbox.shoppingListBox.putMany(
                    [testShoppingList1, testShoppingList2, testShoppingList3]);
              });

              await tester.pumpWidget(getHomeScreen());
              await tester.pumpAndSettle();

              // Test for shopping lists
              expect(find.text(testShoppingList1.name), findsOneWidget);
              expect(find.text(testShoppingList2.name), findsOneWidget);
              expect(find.text(testShoppingList3.name), findsOneWidget);
            },
          );

          testWidgets(
            'Can be removed from screen',
            (tester) async {
              // Setup
              final ShoppingList testShoppingList1 =
                  ShoppingList(name: 'Test Shopping List 1');
              final ShoppingList testShoppingList2 =
                  ShoppingList(name: 'Test Shopping List 2');
              final ShoppingList testShoppingList3 =
                  ShoppingList(name: 'Test Shopping List 3');

              dbSetUp(() {
                objectbox.shoppingListBox.putMany(
                    [testShoppingList1, testShoppingList2, testShoppingList3]);
              });

              await tester.pumpWidget(getHomeScreen());
              await tester.pumpAndSettle();

              // Test for shopping lists
              expect(find.text(testShoppingList1.name), findsOneWidget);
              expect(find.text(testShoppingList2.name), findsOneWidget);
              expect(find.text(testShoppingList3.name), findsOneWidget);

              // Remove second and first shopping lists
              await tester.tap(find.byTooltip('Remove shopping list').at(1));
              await tester.pumpAndSettle();
              await tester.tap(find.byTooltip('Remove shopping list').first);
              await tester.pumpAndSettle();

              await tester.runAsync(
                () async {
                  // Advance time for StreamBuilder to rebuild
                  await Future.delayed(const Duration(microseconds: 500));

                  await tester.pumpAndSettle();

                  // Test for shopping lists
                  expect(find.text(testShoppingList1.name), findsNothing);
                  expect(find.text(testShoppingList2.name), findsNothing);
                  expect(find.text(testShoppingList3.name), findsOneWidget);
                },
              );
            },
          );

          testWidgets(
            'Can be removed from db',
            (tester) async {
              // Setup
              final ShoppingList testShoppingList1 =
                  ShoppingList(name: 'Test Shopping List 1');
              final ShoppingList testShoppingList2 =
                  ShoppingList(name: 'Test Shopping List 2');
              final ShoppingList testShoppingList3 =
                  ShoppingList(name: 'Test Shopping List 3');

              dbSetUp(() {
                objectbox.shoppingListBox.putMany(
                    [testShoppingList1, testShoppingList2, testShoppingList3]);
              });

              await tester.pumpWidget(getHomeScreen());
              await tester.pumpAndSettle();

              // Test for shopping lists
              expect(find.text(testShoppingList1.name), findsOneWidget);
              expect(find.text(testShoppingList2.name), findsOneWidget);
              expect(find.text(testShoppingList3.name), findsOneWidget);

              // Remove second and first shopping lists
              await tester.tap(find.byTooltip('Remove shopping list').at(1));
              await tester.pumpAndSettle();
              await tester.tap(find.byTooltip('Remove shopping list').first);
              await tester.pumpAndSettle();

              // Test for absence of removed shopping lists in obx
              expect(objectbox.shoppingListBox.getAll()[0].name,
                  testShoppingList3.name);
              expect(objectbox.shoppingListBox.getAll().length, 1);
            },
          );

          testWidgets(
            'Screen is updated when a new one is added to db',
            (tester) async {
              // Setup
              final ShoppingList testShoppingList1 =
                  ShoppingList(name: 'Test Shopping List 1');
              final ShoppingList testShoppingList2 =
                  ShoppingList(name: 'Test Shopping List 2');
              final ShoppingList testShoppingList3 =
                  ShoppingList(name: 'Test Shopping List 3');
              final ShoppingList testShoppingList4 =
                  ShoppingList(name: 'Test Shopping List 4');

              dbSetUp(() {
                objectbox.shoppingListBox.putMany(
                    [testShoppingList1, testShoppingList2, testShoppingList3]);
              });

              await tester.pumpWidget(getHomeScreen());
              await tester.pumpAndSettle();

              // Test for shopping lists
              expect(find.text(testShoppingList1.name), findsOneWidget);
              expect(find.text(testShoppingList2.name), findsOneWidget);
              expect(find.text(testShoppingList3.name), findsOneWidget);
              expect(find.text(testShoppingList4.name), findsNothing);

              // Add new shopping list to obx
              objectbox.shoppingListBox.put(testShoppingList4);

              await tester.runAsync(
                () async {
                  // Advance time for StreamBuilder to rebuild
                  await Future.delayed(const Duration(microseconds: 500));

                  await tester.pumpAndSettle();

                  // Test for shopping lists
                  expect(find.text(testShoppingList1.name), findsOneWidget);
                  expect(find.text(testShoppingList2.name), findsOneWidget);
                  expect(find.text(testShoppingList3.name), findsOneWidget);
                  expect(find.text(testShoppingList4.name), findsOneWidget);
                },
              );
            },
          );

          testWidgets(
            'When tapped push ShoppingListScreen',
            (tester) async {
              // Setup
              final ShoppingList testShoppingList =
                  ShoppingList(name: 'Test Shopping List 1');

              dbSetUp(() {
                objectbox.shoppingListBox.put(testShoppingList);
              });

              await tester.pumpWidget(getHomeScreen());
              await tester.pumpAndSettle();

              // Test for presence of ShoppingListScreen
              expect(find.byType(ShoppingListScreen), findsNothing);

              // Tap a shopping list
              await tester.tap(find.text(testShoppingList.name));
              await tester.pumpAndSettle();

              // Test for presence of ShoppingListScreen
              expect(find.byType(ShoppingListScreen), findsOneWidget);
            },
          );
        },
      );

      testWidgets(
        'Display a button to add shopping lists',
        (tester) async {
          // Setup
          dbSetUp();

          await tester.pumpWidget(getHomeScreen());
          await tester.pumpAndSettle();

          // Test for FloatingActionList
          expect(find.byType(FloatingActionButton), findsOneWidget);
        },
      );

      testWidgets(
        'Display AddShoppingList when shopping list add button is pressed',
        (tester) async {
          // Setup
          dbSetUp();

          await tester.pumpWidget(getHomeScreen());
          await tester.pumpAndSettle();

          // Test for absence of AddShoppingList
          expect(find.byType(AddShoppingList), findsNothing);

          // Tap add new shopping list button
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();

          // Test for presence of AddShoppingList
          expect(find.byType(AddShoppingList), findsOneWidget);
        },
      );
    },
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
