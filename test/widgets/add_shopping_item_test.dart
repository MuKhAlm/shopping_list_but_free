import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shopping_list_but_free/models/collection.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/objectbox.g.dart';
import 'package:shopping_list_but_free/widgets/add_shopping_item.dart';

void main() async {
  // Initialize objectbox
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  objectbox = await ObjectBox.open();

  void dbSetUp([Function? populate]) {
    // Empty obx
    objectbox.collectionBox.removeAll();
    objectbox.shoppingItemBox.removeAll();
    objectbox.shoppingItemBox.removeAll();

    // Populate
    if (populate != null) {
      populate();
    }
  }

  Widget getAddShoppingItem(int shoppingListId) => MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: Scaffold(
          body: SizedBox(
            width: 1000,
            height: 1000,
            child: AddShoppingItem(shoppingListId: shoppingListId),
          ),
        ),
      );

  group(
    'AddShoppingItem',
    () {
      group(
        'When submitted',
        () {
          testWidgets(
            'Pops screen',
            (tester) async {
              final ShoppingList testShoppingList =
                  ShoppingList(name: 'Test Shopping List');
              // Setup
              dbSetUp(() {
                objectbox.shoppingListBox.put(testShoppingList);
              });

              await tester.pumpWidget(getAddShoppingItem(
                  objectbox.shoppingListBox.getAll().first.id));
              await tester.pumpAndSettle();

              // Test for Widget
              expect(find.byType(AddShoppingItem), findsOneWidget);

              // Submit
              await tester.tap(find.byTooltip('Submit'));
              await tester.pumpAndSettle();

              // Test for Widget
              expect(find.byType(AddShoppingItem), findsNothing);
            },
          );

          testWidgets(
            'Adds ShoppingItem with typed name to db',
            (tester) async {
              final ShoppingList testShoppingList =
                  ShoppingList(name: 'Test Shopping List');
              // Setup
              dbSetUp(() {
                objectbox.shoppingListBox.put(testShoppingList);
              });

              await tester.pumpWidget(getAddShoppingItem(
                  objectbox.shoppingListBox.getAll().first.id));
              await tester.pumpAndSettle();

              // Enter new shopping item name
              await tester.enterText(
                  find.byType(TextFormField).first, 'New Test Shopping Item');
              await tester.pumpAndSettle();

              // Submit
              await tester.tap(find.byTooltip('Submit'));
              await tester.pumpAndSettle();

              // Test for new shopping item in db
              expect(
                  objectbox.shoppingItemBox
                      .query(
                          ShoppingItem_.name.equals('New Test Shopping Item'))
                      .build()
                      .count(),
                  1);
            },
          );

          testWidgets(
            'Adds ShoppingItem with typed name to Others Collection if no corresponding Collection is found',
            (tester) async {
              final ShoppingList testShoppingList =
                  ShoppingList(name: 'Test Shopping List');
              // Setup
              dbSetUp(() {
                objectbox.shoppingListBox.put(testShoppingList);
              });

              await tester.pumpWidget(getAddShoppingItem(
                  objectbox.shoppingListBox.getAll().first.id));
              await tester.pumpAndSettle();

              // Enter new shopping item name
              await tester.enterText(
                  find.byType(TextFormField).first, 'New Test Shopping Item');
              await tester.pumpAndSettle();

              // Create Others Collection
              Collection others = Collection(name: 'Others');
              objectbox.collectionBox.put(others);

              Query<Collection> othersQuery = objectbox.collectionBox
                  .query(Collection_.name.equals('Others'))
                  .build();
              // Test for Others Collection shoppingItemsNames
              expect(
                  othersQuery
                      .findFirst()!
                      .shoppingItemsNames
                      .contains('new test shopping item'),
                  false);

              // Submit
              await tester.tap(find.byTooltip('Submit'));
              await tester.pumpAndSettle();

              // Test for Others Collection shoppingItemsNames
              expect(
                  othersQuery
                      .findFirst()!
                      .shoppingItemsNames
                      .contains('new test shopping item'),
                  true);
            },
          );

          testWidgets(
            """Creates new Others collection and adds the new
            ShoppingItem to it when there is no others Collection and submitted
            ShoppingItem has no corresponding Collections""",
            (tester) async {
              final ShoppingList testShoppingList =
                  ShoppingList(name: 'Test Shopping List');
              // Setup
              dbSetUp(() {
                objectbox.shoppingListBox.put(testShoppingList);
              });

              await tester.pumpWidget(getAddShoppingItem(
                  objectbox.shoppingListBox.getAll().first.id));
              await tester.pumpAndSettle();

              // Enter new shopping item name
              await tester.enterText(
                  find.byType(TextFormField).first, 'New Test Shopping Item');
              await tester.pumpAndSettle();

              Query<Collection> othersQuery = objectbox.collectionBox
                  .query(Collection_.name.equals('Others'))
                  .build();
              // Test for Others Collection
              expect(othersQuery.count(), 0);

              // Submit
              await tester.tap(find.byTooltip('Submit'));
              await tester.pumpAndSettle();

              // Test for Others Collection presence and shoppingItemsNames
              expect(othersQuery.count(), 1);
              expect(
                  othersQuery
                      .findFirst()!
                      .shoppingItemsNames
                      .contains('new test shopping item'),
                  true);
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
