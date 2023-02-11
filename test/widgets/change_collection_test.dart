import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shopping_list_but_free/models/collection.dart';
import 'package:shopping_list_but_free/models/shopping_item.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/objectbox.g.dart';
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
        shoppingListId: shoppingList.id,
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

          // Tap outside card
          await tester.tapAt(const Offset(5, 5));
          await tester.pumpAndSettle();

          // Test
          expect(find.byType(ChangeCollection), findsNothing);
        },
      );

      testWidgets(
        'Displays a DropdownButtonFormField widget',
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

          // Test
          expect(
              find.byType(DropdownButtonFormField<Collection>), findsOneWidget);
        },
      );

      testWidgets(
        'DropdownButtonFormField widget includes all Collections in db',
        (tester) async {
          // Setup
          testShoppingItem = ShoppingItem(name: 'Test Shopping');
          final testShoppingList = ShoppingList(name: 'Test Shopping List');
          testShoppingList.shoppingItems.add(testShoppingItem);
          final testCollection1 = Collection(name: 'Test Collection 1');
          testCollection1.shoppingItemsNames
              .add(testShoppingItem.name.toLowerCase());
          final testCollection2 = Collection(name: 'Test Collection 2');
          final testCollection3 = Collection(name: 'Test Collection 3');

          dbSetUp(
            () {
              objectbox.shoppingListBox.put(testShoppingList);
              objectbox.collectionBox
                  .putMany([testCollection1, testCollection2, testCollection3]);
            },
          );

          await widgetSetUp(tester, testShoppingList);

          // Tap DropdownButtonFormField
          await tester.tap(find.byType(DropdownButtonFormField<Collection>));
          await tester.pumpAndSettle();

          // Test for collections
          expect(
              find.descendant(
                  of: find.byType(DropdownButtonFormField<Collection>),
                  matching: find.text(testCollection1.name)),
              findsOneWidget);
          expect(
              find.descendant(
                  of: find.byType(DropdownButtonFormField<Collection>),
                  matching: find.text(testCollection2.name)),
              findsOneWidget);
          expect(
              find.descendant(
                  of: find.byType(DropdownButtonFormField<Collection>),
                  matching: find.text(testCollection3.name)),
              findsOneWidget);
        },
      );

      testWidgets(
        'Displays submit button',
        (tester) async {
          // Setup
          testShoppingItem = ShoppingItem(name: 'Test Shopping');
          final testShoppingList = ShoppingList(name: 'Test Shopping List');
          testShoppingList.shoppingItems.add(testShoppingItem);
          final testCollection1 = Collection(name: 'Test Collection 1');
          testCollection1.shoppingItemsNames
              .add(testShoppingItem.name.toLowerCase());
          final testCollection2 = Collection(name: 'Test Collection 2');
          final testCollection3 = Collection(name: 'Test Collection 3');

          dbSetUp(
            () {
              objectbox.shoppingListBox.put(testShoppingList);
              objectbox.collectionBox
                  .putMany([testCollection1, testCollection2, testCollection3]);
            },
          );

          await widgetSetUp(tester, testShoppingList);

          // Test for submit button
          expect(find.byTooltip('Submit'), findsOneWidget);
        },
      );

      testWidgets(
        'Submitting after choosing a Collection changes correct Collections in db',
        (tester) async {
          // Setup
          testShoppingItem = ShoppingItem(name: 'Test Shopping');
          final testShoppingList = ShoppingList(name: 'Test Shopping List');
          testShoppingList.shoppingItems.add(testShoppingItem);
          final testCollection1 = Collection(name: 'Test Collection 1');
          testCollection1.shoppingItemsNames
              .add(testShoppingItem.name.toLowerCase());
          final testCollection2 = Collection(name: 'Test Collection 2');
          final testCollection3 = Collection(name: 'Test Collection 3');

          dbSetUp(
            () {
              objectbox.shoppingListBox.put(testShoppingList);
              objectbox.collectionBox
                  .putMany([testCollection1, testCollection2, testCollection3]);
            },
          );

          await widgetSetUp(tester, testShoppingList);

          // Tap DropdownButtonFormField
          await tester.tap(find.byType(DropdownButtonFormField<Collection>));
          await tester.pumpAndSettle();

          // Tap test collection 2
          // Tapping on the first Text with testCollection2.name results in an error
          // which is caused by tapping a Widget that can't be tapped
          await tester.tap(find.text(testCollection2.name).last);
          await tester.pumpAndSettle();

          // Tap submit
          await tester.tap(find.byTooltip('Submit'));
          await tester.pumpAndSettle();

          // Test for Collections
          expect(
              objectbox.collectionBox
                  .query(Collection_.shoppingItemsNames
                      .containsElement(testShoppingItem.name.toLowerCase()))
                  .build()
                  .findFirst()!
                  .name,
              testCollection2.name);
        },
      );

      testWidgets(
        'Submitting after choosing a Collection pops Widget',
        (tester) async {
          // Setup
          testShoppingItem = ShoppingItem(name: 'Test Shopping');
          final testShoppingList = ShoppingList(name: 'Test Shopping List');
          testShoppingList.shoppingItems.add(testShoppingItem);
          final testCollection1 = Collection(name: 'Test Collection 1');
          testCollection1.shoppingItemsNames
              .add(testShoppingItem.name.toLowerCase());
          final testCollection2 = Collection(name: 'Test Collection 2');
          final testCollection3 = Collection(name: 'Test Collection 3');

          dbSetUp(
            () {
              objectbox.shoppingListBox.put(testShoppingList);
              objectbox.collectionBox
                  .putMany([testCollection1, testCollection2, testCollection3]);
            },
          );

          await widgetSetUp(tester, testShoppingList);

          // Tap DropdownButtonFormField
          await tester.tap(find.byType(DropdownButtonFormField<Collection>));
          await tester.pumpAndSettle();

          // Tap test collection 2
          // Tapping on the first Text with testCollection2.name results in an error
          // which is caused by tapping a Widget that can't be tapped
          await tester.tap(find.text(testCollection2.name).last);
          await tester.pumpAndSettle();

          // Tap submit
          await tester.tap(find.byTooltip('Submit'));
          await tester.pumpAndSettle();

          // Test for ChangeCollection
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
