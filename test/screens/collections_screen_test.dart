import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shopping_list_but_free/models/collection.dart';
import 'package:shopping_list_but_free/models/shopping_item.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/screens/collections_screen.dart';
import 'package:shopping_list_but_free/widgets/add_collection.dart';
import 'package:shopping_list_but_free/widgets/add_shopping_item_name.dart';
import 'package:shopping_list_but_free/widgets/change_collection_name.dart';

void main() async {
  // Initialize objectbox
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  objectbox = await ObjectBox.open();

  /// Sets
  void dbSetup(Function() populate) {
    // Empty obx
    objectbox.collectionBox.removeAll();
    objectbox.shoppingListBox.removeAll();
    objectbox.shoppingItemBox.removeAll();

    // Populate
    populate();
  }

  Widget getCollectionsScreen() {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const CollectionsScreen(),
    );
  }

  group(
    'CollectionsScreen',
    () {
      group(
        'AppBar',
        () {
          testWidgets(
            'Displays correct title',
            (tester) async {
              // Setup obx
              dbSetup(() {});

              // Setup widget
              await tester.pumpWidget(getCollectionsScreen());
              await tester.pumpAndSettle();

              // Test for title
              expect(find.text('Collections'), findsOneWidget);
            },
          );

          testWidgets(
            'Displays nav menu',
            (tester) async {
              // Setup obx
              dbSetup(() {});

              // Setup widget
              await tester.pumpWidget(getCollectionsScreen());
              await tester.pumpAndSettle();

              // Test for menu
              expect(find.byTooltip('Open navigation menu'), findsOneWidget);
            },
          );
        },
      );

      testWidgets(
        'Displays correct collections',
        (tester) async {
          final testCollection1 = Collection(name: 'Test Collection 1');
          final testCollection2 = Collection(name: 'Test Collection 2');
          final testCollection3 = Collection(name: 'Test Collection 3');

          // Setup obx
          dbSetup(() {
            objectbox.collectionBox.put(testCollection1);
            objectbox.collectionBox.put(testCollection2);
            objectbox.collectionBox.put(testCollection3);
          });

          // Setup widget
          await tester.pumpWidget(getCollectionsScreen());
          await tester.pumpAndSettle();

          // Test for Collections
          expect(find.text(testCollection1.name), findsOneWidget);
          expect(find.text(testCollection2.name), findsOneWidget);
          expect(find.text(testCollection3.name), findsOneWidget);
        },
      );

      group(
        'each collection panel',
        () {
          testWidgets(
            'Initially expanded and retracts correctly',
            (tester) async {
              final testCollection1 = Collection(name: 'Test Collection 1');
              final testCollection2 = Collection(name: 'Test Collection 2');
              final testCollection3 = Collection(name: 'Test Collection 3');

              // Setup obx
              dbSetup(() {
                objectbox.collectionBox.put(testCollection1);
                objectbox.collectionBox.put(testCollection2);
                objectbox.collectionBox.put(testCollection3);
              });

              // Setup widget
              await tester.pumpWidget(getCollectionsScreen());
              await tester.pumpAndSettle();

              // Get ExpansionPanelList initial height
              RenderBox box =
                  tester.renderObject(find.byType(ExpansionPanelList));
              final double oldHeight = box.size.height;

              // Tap second panel to retract it
              await tester.tap(find.text(testCollection2.name));
              await tester.pumpAndSettle();

              // Expect ExpansionPanelList height to be less
              expect(box.size.height, lessThan(oldHeight));
            },
          );

          testWidgets(
            'Expands correctly after retraction',
            (tester) async {
              final testCollection1 = Collection(name: 'Test Collection 1');
              final testCollection2 = Collection(name: 'Test Collection 2');
              final testCollection3 = Collection(name: 'Test Collection 3');

              // Setup obx
              dbSetup(() {
                objectbox.collectionBox.put(testCollection1);
                objectbox.collectionBox.put(testCollection2);
                objectbox.collectionBox.put(testCollection3);
              });

              // Setup widget
              await tester.pumpWidget(getCollectionsScreen());
              await tester.pumpAndSettle();

              // Get ExpansionPanelList initial height
              RenderBox box =
                  tester.renderObject(find.byType(ExpansionPanelList));
              final double oldHeight = box.size.height;

              // Tap second panel to retract it
              await tester.tap(find.text(testCollection2.name));
              await tester.pumpAndSettle();

              // Expect ExpansionPanelList height to be less
              expect(box.size.height, lessThan(oldHeight));

              // Tap second panel to expand it
              await tester.tap(find.text(testCollection2.name));
              await tester.pumpAndSettle();

              // Expect ExpansionPanelList height to be equal to initial height
              expect(box.size.height, oldHeight);
            },
          );

          group(
            'Option Menu',
            () {
              testWidgets(
                'Is displayed',
                (tester) async {
                  final testCollection1 = Collection(name: 'Test Collection 1');

                  // Setup obx
                  dbSetup(() {
                    objectbox.collectionBox.put(testCollection1);
                  });

                  // Setup widget
                  await tester.pumpWidget(getCollectionsScreen());
                  await tester.pumpAndSettle();

                  // Test for options menu
                  expect(find.byTooltip('Collection options'), findsOneWidget);
                },
              );

              testWidgets(
                'Displays Change Name and Delete options',
                (tester) async {
                  final testCollection1 = Collection(name: 'Test Collection 1');

                  // Setup obx
                  dbSetup(() {
                    objectbox.collectionBox.put(testCollection1);
                  });

                  // Setup widget
                  await tester.pumpWidget(getCollectionsScreen());
                  await tester.pumpAndSettle();

                  // Tap options menu
                  await tester.tap(find.byTooltip('Collection options'));
                  await tester.pumpAndSettle();

                  // Test for options
                  expect(find.text('Add\nItem'), findsOneWidget);
                  expect(find.text('Change\nName'), findsOneWidget);
                  expect(find.text('Delete'), findsOneWidget);
                },
              );

              testWidgets(
                'Display AddShoppingItemName Widget when Change Name option is pressed',
                (tester) async {
                  final testCollection1 = Collection(name: 'Test Collection 1');

                  // Setup obx
                  dbSetup(() {
                    objectbox.collectionBox.put(testCollection1);
                  });

                  // Setup widget
                  await tester.pumpWidget(getCollectionsScreen());
                  await tester.pumpAndSettle();

                  // Tap options menu
                  await tester.tap(find.byTooltip('Collection options'));
                  await tester.pumpAndSettle();

                  // Test for AddShoppingItemName
                  expect(find.byType(AddShoppingItemName), findsNothing);

                  // Tap Change Name option
                  await tester.tap(find.text('Add\nItem'));
                  await tester.pumpAndSettle();

                  // Test for AddShoppingItemName
                  expect(find.byType(AddShoppingItemName), findsOneWidget);
                },
              );

              testWidgets(
                'Display ChangeCollectionName Widget when Change Name option is pressed',
                (tester) async {
                  final testCollection1 = Collection(name: 'Test Collection 1');

                  // Setup obx
                  dbSetup(() {
                    objectbox.collectionBox.put(testCollection1);
                  });

                  // Setup widget
                  await tester.pumpWidget(getCollectionsScreen());
                  await tester.pumpAndSettle();

                  // Tap options menu
                  await tester.tap(find.byTooltip('Collection options'));
                  await tester.pumpAndSettle();

                  // Test for ChangeCollectionName
                  expect(find.byType(ChangeCollectionName), findsNothing);

                  // Tap Change Name option
                  await tester.tap(find.text('Change\nName'));
                  await tester.pumpAndSettle();

                  // Test for ChangeCollectionName
                  expect(find.byType(ChangeCollectionName), findsOneWidget);
                },
              );

              group(
                'When Delete option is pressed',
                () {
                  testWidgets(
                    'Deletes collection from db',
                    (tester) async {
                      final testCollection1 =
                          Collection(name: 'Test Collection 1');
                      final testOthers = Collection(name: 'Others');

                      // Setup obx
                      dbSetup(() {
                        objectbox.collectionBox.put(testCollection1);
                        objectbox.collectionBox.put(testOthers);
                      });

                      // Setup widget
                      await tester.pumpWidget(getCollectionsScreen());
                      await tester.pumpAndSettle();

                      // Tap options menu
                      await tester
                          .tap(find.byTooltip('Collection options').first);
                      await tester.pumpAndSettle();

                      // Test for Collection in obx
                      expect(
                          objectbox.collectionBox.get(testCollection1.id) ==
                              null,
                          false);

                      // Tap Delete option
                      await tester.tap(find.text('Delete'));
                      await tester.pumpAndSettle();

                      // Test for Collection in obx
                      expect(objectbox.collectionBox.get(testCollection1.id),
                          null);
                    },
                  );

                  testWidgets(
                    """"'Deletes collection from db and adds shopping item names
                    which there is a ShoppingItem with the same name in a 
                    ShoppingList to the Others Collection""",
                    (tester) async {
                      final testShoppingItem1 =
                          ShoppingItem(name: 'Test Shopping Item 1');

                      final testShoppingList1 =
                          ShoppingList(name: 'Test Shopping List 1');

                      testShoppingList1.shoppingItems.add(testShoppingItem1);

                      final testCollection1 =
                          Collection(name: 'Test Collection 1');
                      final testOthers = Collection(name: 'Others');

                      testCollection1.shoppingItemsNames
                          .add(testShoppingItem1.name.toLowerCase());
                      testCollection1.shoppingItemsNames
                          .add('test shopping item 2');

                      // Setup obx
                      dbSetup(() {
                        objectbox.shoppingListBox.put(testShoppingList1);
                        objectbox.collectionBox.put(testCollection1);
                        objectbox.collectionBox.put(testOthers);
                      });

                      // Setup widget
                      await tester.pumpWidget(getCollectionsScreen());
                      await tester.pumpAndSettle();

                      // Tap options menu
                      await tester
                          .tap(find.byTooltip('Collection options').first);
                      await tester.pumpAndSettle();

                      // Test for shoppingItemNames in Others Collection
                      expect(
                          objectbox.collectionBox
                              .get(testOthers.id)!
                              .shoppingItemsNames
                              .isEmpty,
                          true);

                      // Tap Delete option
                      await tester.tap(find.text('Delete'));
                      await tester.pumpAndSettle();

                      // Test for shoppingItemNames in Others Collection
                      expect(
                          objectbox.collectionBox
                              .get(testOthers.id)!
                              .shoppingItemsNames[0],
                          testShoppingItem1.name.toLowerCase());
                      expect(
                          objectbox.collectionBox
                              .get(testOthers.id)!
                              .shoppingItemsNames
                              .length,
                          1);
                    },
                  );
                },
              );
            },
          );

          group(
            'Each shopping item name tile',
            () {
              testWidgets(
                'When delete icon is pressed, remove shopping item name from Collection',
                (tester) async {
                  final testCollection1 = Collection(name: 'Test Collection 1');
                  final testOthers = Collection(name: 'Others');

                  testCollection1.shoppingItemsNames
                      .add('test shopping item 1');

                  // Setup obx
                  dbSetup(() {
                    objectbox.collectionBox.put(testCollection1);
                    objectbox.collectionBox.put(testOthers);
                  });

                  // Setup widget
                  await tester.pumpWidget(getCollectionsScreen());
                  await tester.pumpAndSettle();

                  // Test for testCollection1 shoppingItemNames
                  expect(
                      objectbox.collectionBox
                          .get(testCollection1.id)!
                          .shoppingItemsNames
                          .isNotEmpty,
                      true);

                  // Delete shopping item name
                  await tester.tap(find
                      .byTooltip('Remove shopping item name from collection'));
                  await tester.pumpAndSettle();

                  // Test for testCollection1 shoppingItemNames
                  expect(
                      objectbox.collectionBox
                          .get(testCollection1.id)!
                          .shoppingItemsNames
                          .isEmpty,
                      true);
                  expect(
                      objectbox.collectionBox
                          .get(testOthers.id)!
                          .shoppingItemsNames
                          .isEmpty,
                      true);
                },
              );

              testWidgets(
                """When delete icon is pressed, move shopping item from collection
                to the Others collection if a ShoppingItem with same name is in a ShoppingList""",
                (tester) async {
                  final testShoppingItem1 =
                      ShoppingItem(name: 'Test Shopping Item 1');

                  final testShoppingList1 =
                      ShoppingList(name: 'Test Shopping List 1');

                  testShoppingList1.shoppingItems.add(testShoppingItem1);

                  final testCollection1 = Collection(name: 'Test Collection 1');
                  final testOthers = Collection(name: 'Others');

                  testCollection1.shoppingItemsNames
                      .add(testShoppingItem1.name.toLowerCase());

                  // Setup obx
                  dbSetup(() {
                    objectbox.shoppingListBox.put(testShoppingList1);
                    objectbox.collectionBox.put(testCollection1);
                    objectbox.collectionBox.put(testOthers);
                  });

                  // Setup widget
                  await tester.pumpWidget(getCollectionsScreen());
                  await tester.pumpAndSettle();

                  // Test for testCollection1 shoppingItemNames
                  expect(
                      objectbox.collectionBox
                          .get(testCollection1.id)!
                          .shoppingItemsNames
                          .isNotEmpty,
                      true);
                  expect(
                      objectbox.collectionBox
                          .get(testOthers.id)!
                          .shoppingItemsNames
                          .isEmpty,
                      true);

                  // Delete shopping item name
                  await tester.tap(find
                      .byTooltip('Remove shopping item name from collection'));
                  await tester.pumpAndSettle();

                  // Test for testCollection1 and testOthers shoppingItemNames
                  expect(
                      objectbox.collectionBox
                          .get(testCollection1.id)!
                          .shoppingItemsNames
                          .isEmpty,
                      true);
                  expect(
                      objectbox.collectionBox
                          .get(testOthers.id)!
                          .shoppingItemsNames
                          .isNotEmpty,
                      true);
                },
              );
            },
          );
        },
      );

      testWidgets(
        'Displays all shopping item names',
        (tester) async {
          final testCollection1 = Collection(name: 'Test Collection 1');
          final testCollection2 = Collection(name: 'Test Collection 2');
          final testCollection3 = Collection(name: 'Test Collection 3');

          testCollection1.shoppingItemsNames.add('test shopping item 1');
          testCollection1.shoppingItemsNames.add('test shopping item 2');
          testCollection2.shoppingItemsNames.add('test shopping item 3');
          testCollection3.shoppingItemsNames.add('test shopping item 4');
          testCollection3.shoppingItemsNames.add('test shopping item 5');

          // Setup obx
          dbSetup(() {
            objectbox.collectionBox.put(testCollection1);
            objectbox.collectionBox.put(testCollection2);
            objectbox.collectionBox.put(testCollection3);
          });

          // Setup widget
          await tester.pumpWidget(getCollectionsScreen());
          await tester.pumpAndSettle();

          // Test for shopping item names
          expect(find.text('test shopping item 1'), findsOneWidget);
          expect(find.text('test shopping item 2'), findsOneWidget);
          expect(find.text('test shopping item 3'), findsOneWidget);
          expect(find.text('test shopping item 4'), findsOneWidget);
          expect(find.text('test shopping item 5'), findsOneWidget);
        },
      );

      testWidgets(
        'Displays FloatingActionButton that displays AddCollection Widget when pressed',
        (tester) async {
          // Setup obx
          dbSetup(() {});

          // Setup widget
          await tester.pumpWidget(getCollectionsScreen());
          await tester.pumpAndSettle();

          // Test for AddCollection
          expect(find.byType(AddCollection), findsNothing);

          // Tap FloatingActionButton
          await tester.tap(find.byTooltip('Add a new collection'));
          await tester.pumpAndSettle();

          // Test for AddCollection
          expect(find.byType(AddCollection), findsOneWidget);
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
