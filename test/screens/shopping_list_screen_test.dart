import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shopping_list_but_free/models/shopping_item.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/screens/shopping_list_screen.dart';

void main() async {
  // Initialize objectbox
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  objectbox = await ObjectBox.open();

  late ShoppingList shoppingList;

  /// Empties database and populates it
  void setUp(Function populate) {
    // Empty database
    objectbox.shoppingListBox.removeAll();
    objectbox.shoppingItemBox.removeAll();
    objectbox.collectionBox.removeAll();

    // Populate database
    populate();
  }

  Widget _getShoppingListScreen() => MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: ShoppingListScreen(
          shoppingList: shoppingList,
        ),
      );

  group(
    'ShoppingListScreen',
    () {
      group(
        'AppBar',
        () {
          testWidgets(
            'Display correct title',
            (tester) async {
              // Set shoppingList
              shoppingList = ShoppingList(name: 'Test Shopping List');

              setUp(() {
                objectbox.shoppingListBox.put(shoppingList);
              });

              // Pump ShoppingListScreen
              await tester.pumpWidget(_getShoppingListScreen());

              // Test for correct title
              expect(find.text('Test Shopping List'), findsOneWidget);
            },
          );

          testWidgets(
            'Display navigation menu',
            (tester) async {
              // Set shoppingList
              shoppingList = ShoppingList(name: 'Test Shopping List');

              setUp(() {
                objectbox.shoppingListBox.put(shoppingList);
              });

              // Pump ShoppingListScreen
              await tester.pumpWidget(_getShoppingListScreen());

              // Test for correct title
              expect(find.byTooltip('Open navigation menu'), findsOneWidget);
            },
          );

          group(
            'Popup Menu',
            () {
              Future<void> popUpMenuSetup(WidgetTester tester) async {
                // Set shoppingList
                shoppingList = ShoppingList(name: 'Test Shopping List');

                setUp(() {
                  shoppingList.shoppingItems
                      .add(ShoppingItem(name: 'Test Shopping Item 1'));
                  shoppingList.shoppingItems
                      .add(ShoppingItem(name: 'Test Shopping Item 2'));
                  objectbox.shoppingListBox.put(shoppingList);
                });

                // Pump ShoppingListScreen
                await tester.pumpWidget(_getShoppingListScreen());

                // Tap popup menu
                await tester.tap(find.byTooltip('Show menu'));
                await tester.pumpAndSettle();
              }

              testWidgets(
                'Display popup menu',
                (tester) async {
                  // Set shoppingList
                  shoppingList = ShoppingList(name: 'Test Shopping List');

                  setUp(() {
                    objectbox.shoppingListBox.put(shoppingList);
                  });

                  // Pump ShoppingListScreen
                  await tester.pumpWidget(_getShoppingListScreen());

                  // Test for correct title
                  expect(find.byTooltip('Show menu'), findsOneWidget);
                },
              );

              testWidgets(
                'Tapping on popup menu displays delete option',
                (tester) async {
                  await popUpMenuSetup(tester);

                  // Test for delete option
                  expect(find.text('Delete'), findsOneWidget);
                },
              );

              testWidgets(
                'Tapping on delete option deletes all shopping items in list',
                (tester) async {
                  await popUpMenuSetup(tester);

                  // Tap delete option
                  await tester.tap(find.text('Delete'));
                  await tester.pumpAndSettle();

                  // Test for shopping items in database
                  expect(objectbox.shoppingItemBox.isEmpty(), true);
                },
              );

              testWidgets(
                'Tapping on delete option deletes shopping list',
                (tester) async {
                  await popUpMenuSetup(tester);

                  // Tap delete option
                  await tester.tap(find.text('Delete'));
                  await tester.pumpAndSettle();

                  // Test for shopping list in database
                  expect(objectbox.shoppingListBox.get(shoppingList.id), null);
                },
              );

              testWidgets(
                'Tapping on delete option pops screen',
                (tester) async {
                  await popUpMenuSetup(tester);

                  // Tap delete option
                  await tester.tap(find.text('Delete'));
                  await tester.pumpAndSettle();

                  // Test for absence of ShoppingListScreen
                  expect(find.byType(ShoppingListScreen), findsNothing);
                },
              );
            },
          );
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
