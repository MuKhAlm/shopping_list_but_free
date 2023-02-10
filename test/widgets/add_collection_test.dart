import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shopping_list_but_free/models/collection.dart';
import 'package:shopping_list_but_free/models/shopping_item.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/objectbox.g.dart';
import 'package:shopping_list_but_free/widgets/add_collection.dart';

void main() async {
  // Initialize objectbox
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  objectbox = await ObjectBox.open();

  late ShoppingItem testShoppingItem;

  MaterialApp getAddCollection([ShoppingItem? shoppingItem]) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SizedBox(
          width: 1000,
          height: 1000,
          child: AddCollection(
            shoppingItem: shoppingItem,
          ),
        ),
      ),
    );
  }

  void dbSetUp(Function populate) {
    // Empty database
    objectbox.shoppingListBox.removeAll();
    objectbox.shoppingItemBox.removeAll();
    objectbox.collectionBox.removeAll();

    // Populate
    populate();
  }

  group(
    'AddCollection',
    () {
      group(
        'When submitted',
        () {
          testWidgets(
            'Adds Collection with typed name to db',
            (tester) async {
              // Setup
              dbSetUp(() {});

              await tester.pumpWidget(getAddCollection());
              await tester.pumpAndSettle();

              // Enter new collection name
              await tester.enterText(
                  find.byType(TextFormField).first, 'New Test Collection');
              await tester.pumpAndSettle();

              // Submit
              await tester.tap(find.byTooltip('Submit'));
              await tester.pumpAndSettle();

              // Test for new Collection in db
              expect(
                  objectbox.collectionBox
                      .query(Collection_.name.equals('New Test Collection'))
                      .build()
                      .findFirst()!
                      .name,
                  'New Test Collection');
            },
          );

          testWidgets(
            'Adds Collection with typed name to db when a ShoppingItem is provided',
            (tester) async {
              // Setup
              testShoppingItem = ShoppingItem(name: 'Test Shopping Item');
              final Collection testCollection =
                  Collection(name: 'Test Collection');
              testCollection.shoppingItemsNames
                  .add(testShoppingItem.name.toLowerCase());

              dbSetUp(
                () {
                  objectbox.shoppingItemBox.put(testShoppingItem);
                  objectbox.collectionBox.put(testCollection);
                },
              );

              await tester.pumpWidget(getAddCollection(testShoppingItem));
              await tester.pumpAndSettle();

              // Enter new collection name
              await tester.enterText(
                  find.byType(TextFormField).first, 'New Test Collection');
              await tester.pumpAndSettle();

              // Submit
              await tester.tap(find.byTooltip('Submit'));
              await tester.pumpAndSettle();

              // Test for new Collection in db
              expect(
                  objectbox.collectionBox
                      .query(Collection_.name.equals('New Test Collection'))
                      .build()
                      .findFirst()!
                      .name,
                  'New Test Collection');
            },
          );

          testWidgets(
            'Adds shoppingItem name to the new Collection\'s shoppingItemNames when a ShoppingItem is provided',
            (tester) async {
              // Setup
              testShoppingItem = ShoppingItem(name: 'Test Shopping Item');
              final Collection testCollection =
                  Collection(name: 'Test Collection');
              testCollection.shoppingItemsNames
                  .add(testShoppingItem.name.toLowerCase());

              dbSetUp(
                () {
                  objectbox.shoppingItemBox.put(testShoppingItem);
                  objectbox.collectionBox.put(testCollection);
                },
              );

              await tester.pumpWidget(getAddCollection(testShoppingItem));
              await tester.pumpAndSettle();

              // Enter new collection name
              await tester.enterText(
                  find.byType(TextFormField).first, 'New Test Collection');
              await tester.pumpAndSettle();

              // Submit
              await tester.tap(find.byTooltip('Submit'));
              await tester.pumpAndSettle();

              // Test for new Collection in db
              expect(
                  objectbox.collectionBox
                      .query(Collection_.name.equals('New Test Collection'))
                      .build()
                      .findFirst()!
                      .shoppingItemsNames
                      .contains(testShoppingItem.name.toLowerCase()),
                  true);
            },
          );

          testWidgets(
            'Removes shoppingItem name form prev Collection when a ShoppingItem is provided',
            (tester) async {
              // Setup
              testShoppingItem = ShoppingItem(name: 'Test Shopping Item');
              final Collection testCollection =
                  Collection(name: 'Test Collection');
              testCollection.shoppingItemsNames
                  .add(testShoppingItem.name.toLowerCase());

              dbSetUp(
                () {
                  objectbox.shoppingItemBox.put(testShoppingItem);
                  objectbox.collectionBox.put(testCollection);
                },
              );

              await tester.pumpWidget(getAddCollection(testShoppingItem));
              await tester.pumpAndSettle();

              // Enter new collection name
              await tester.enterText(
                  find.byType(TextFormField).first, 'New Test Collection');
              await tester.pumpAndSettle();

              // Submit
              await tester.tap(find.byTooltip('Submit'));
              await tester.pumpAndSettle();

              // Test for absence of prev Collection
              expect(
                  objectbox.collectionBox
                      .query(Collection_.name.equals('New Test Collection'))
                      .build()
                      .findFirst()!
                      .name,
                  'New Test Collection');
              expect(
                  objectbox.collectionBox
                      .query(Collection_.name.equals('New Test Collection'))
                      .build()
                      .find()
                      .length,
                  1);
            },
          );

          testWidgets(
            'Pops Widget',
            (tester) async {
              // Setup
              testShoppingItem = ShoppingItem(name: 'Test Shopping Item');
              final Collection testCollection =
                  Collection(name: 'Test Collection');
              testCollection.shoppingItemsNames
                  .add(testShoppingItem.name.toLowerCase());

              dbSetUp(
                () {
                  objectbox.shoppingItemBox.put(testShoppingItem);
                  objectbox.collectionBox.put(testCollection);
                },
              );

              await tester.pumpWidget(getAddCollection(testShoppingItem));
              await tester.pumpAndSettle();

              // Enter new collection name
              await tester.enterText(
                  find.byType(TextFormField).first, 'New Test Collection');
              await tester.pumpAndSettle();

              // Submit
              await tester.tap(find.byTooltip('Submit'));
              await tester.pumpAndSettle();

              // Test for absence of AddCollection
              expect(find.byType(AddCollection), findsNothing);
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
