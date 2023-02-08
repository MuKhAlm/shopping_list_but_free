import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shopping_list_but_free/models/collection.dart';
import 'package:shopping_list_but_free/models/shopping_item.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/screens/shopping_list_screen.dart';
import 'package:shopping_list_but_free/widgets/change_collection.dart';

void main() async {
  // Initialize objectbox
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  objectbox = await ObjectBox.open();

  late ShoppingItem testShoppingItem;

  void dbSetUp(Function populate) {
    // Empty database
    objectbox.shoppingListBox.removeAll();
    objectbox.shoppingItemBox.removeAll();
    objectbox.collectionBox.removeAll();

    // Populate
    populate();
  }

  Future<void> widgetSetUp(
      WidgetTester tester, ShoppingList shoppingList) async {
    // Pump Widget
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: ShoppingListScreen(
        shoppingList: shoppingList,
      ),
    ));
    await tester.pumpAndSettle();

    // Tap options menu
    await tester.tap(find.byTooltip('Shopping item options'));
    await tester.pumpAndSettle();

    // Tap change collection option
    await tester.tap(find.text('Change\nCollection'));
    await tester.pumpAndSettle();

    // Test for ChangeCollection Widget
    expect(find.byType(ChangeCollection), findsOneWidget);
  }

  group(
    'ChangeCollection',
    () {
      testWidgets(
        'Pops when tapped on back arrow',
        (tester) async {
          // Setup
          testShoppingItem = ShoppingItem(name: 'Test Shopping');
          final testShoppingList = ShoppingList(name: 'Test Shopping List');
          testShoppingList.shoppingItems.add(testShoppingItem);
          final testCollection = Collection(name: 'Test Collection');
          testCollection.shoppingItemsNames
              .add(testShoppingItem.name.toLowerCase());

          dbSetUp(
            () {
              objectbox.shoppingListBox.put(testShoppingList);
              objectbox.collectionBox.put(testCollection);
            },
          );

          await widgetSetUp(tester, testShoppingList);

          // Tap back arrow
          await tester.tap(find.byTooltip('Back'));
          await tester.pumpAndSettle();

          // Test
          expect(find.byType(ChangeCollection), findsNothing);
        },
      );

      testWidgets(
        'Pops when tapped outside card (shaded area)',
        (tester) async {
          // Setup
          testShoppingItem = ShoppingItem(name: 'Test Shopping');
          final testShoppingList = ShoppingList(name: 'Test Shopping List');
          testShoppingList.shoppingItems.add(testShoppingItem);
          final testCollection = Collection(name: 'Test Collection');
          testCollection.shoppingItemsNames
              .add(testShoppingItem.name.toLowerCase());

          dbSetUp(
            () {
              objectbox.shoppingListBox.put(testShoppingList);
              objectbox.collectionBox.put(testCollection);
            },
          );

          await widgetSetUp(tester, testShoppingList);

          // Tap back arrow
          await tester.tapAt(const Offset(5, 5));
          await tester.pumpAndSettle();

          // Test
          expect(find.byType(ChangeCollection), findsNothing);
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
