import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shopping_list_but_free/models/collection.dart';
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

  Widget getShoppingListScreen() => MaterialApp(
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
              await tester.pumpWidget(getShoppingListScreen());

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
              await tester.pumpWidget(getShoppingListScreen());

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
                await tester.pumpWidget(getShoppingListScreen());

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
                  await tester.pumpWidget(getShoppingListScreen());

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

      group(
        'Collection Panels',
        () {
          Future<void> collectionPanelsSetUp(
            Collection collection,
            WidgetTester tester,
          ) async {
            setUp(() {
              // Collections
              collection.shoppingItemsNames.addAll(
                  <String>['test shopping item 1', 'test shopping item 2']);
              objectbox.collectionBox.put(collection);
              // Shopping Items
              shoppingList.shoppingItems
                  .add(ShoppingItem(name: 'Test Shopping Item 1'));
              shoppingList.shoppingItems
                  .add(ShoppingItem(name: 'Test Shopping Item 2'));
              objectbox.shoppingListBox.put(shoppingList);
            });

            // Pump ShoppingListScreen
            await tester.pumpWidget(getShoppingListScreen());
            await tester.pumpAndSettle();
          }

          testWidgets(
            'Initially expanded and retracts correctly',
            (tester) async {
              // Set shoppingList
              shoppingList = ShoppingList(name: 'Test Shopping List');
              Collection collection = Collection(name: 'Test Collection');

              // Setup
              await collectionPanelsSetUp(collection, tester);

              // Get ExpansionPanelList initial height
              RenderBox box =
                  tester.renderObject(find.byType(ExpansionPanelList));
              final double oldHeight = box.size.height;

              // Tap first panel to retract it
              await tester.tap(find.text('Test Collection'));
              await tester.pumpAndSettle();

              // Expect ExpansionPanelList height to be less
              expect(box.size.height, lessThan(oldHeight));
            },
          );

          testWidgets(
            'Display only relevant collections',
            (tester) async {
              shoppingList = ShoppingList(name: 'Test Shopping List');
              shoppingList.shoppingItems
                  .add(ShoppingItem(name: 'Test Shopping Item 1'));
              Collection collection1 = Collection(name: 'Test Collection 1');
              Collection collection2 = Collection(name: 'Test Collection 2');
              collection1.shoppingItemsNames.add('test shopping item 1');
              collection2.shoppingItemsNames.add('test shopping item 2');

              setUp(() {
                objectbox.shoppingListBox.put(shoppingList);
                objectbox.collectionBox.put(collection1);
                objectbox.collectionBox.put(collection2);
              });

              await tester.pumpWidget(getShoppingListScreen());
              await tester.pumpAndSettle();

              // Test for presence of collection1 and absence of collection2
              expect(find.text(collection1.name), findsOneWidget);
              expect(find.text(collection2.name), findsNothing);
            },
          );

          testWidgets(
            'Display only relevant ShoppingItems for each Collection',
            (tester) async {
              // TODO: Implement (needs implementing collections removal first)
            },
          );
        },
      );

      group(
        'Shopping item tile',
        () {
          testWidgets(
            'Display initial checked initial status correctly',
            (tester) async {
              shoppingList = ShoppingList(name: 'Test Shopping List');
              final ShoppingItem shoppingItem =
                  ShoppingItem(name: 'Test Shopping Item');
              shoppingList.shoppingItems.add(shoppingItem);

              final Collection collection = Collection(name: 'Test Collection');
              collection.shoppingItemsNames.add('test shopping item');

              setUp(() {
                objectbox.shoppingListBox.put(shoppingList);
                objectbox.collectionBox.put(collection);
              });

              await tester.pumpWidget(getShoppingListScreen());
              await tester.pumpAndSettle();

              // Test by tooltips
              expect(find.byTooltip('Check shopping item'), findsOneWidget);
            },
          );

          testWidgets(
            'Display initial unchecked initial status correctly',
            (tester) async {
              shoppingList = ShoppingList(name: 'Test Shopping List');
              final ShoppingItem shoppingItem =
                  ShoppingItem(name: 'Test Shopping Item');
              shoppingItem.checked = true;
              shoppingList.shoppingItems.add(shoppingItem);

              final Collection collection = Collection(name: 'Test Collection');
              collection.shoppingItemsNames.add('test shopping item');

              setUp(() {
                objectbox.shoppingListBox.put(shoppingList);
                objectbox.collectionBox.put(collection);
              });

              await tester.pumpWidget(getShoppingListScreen());
              await tester.pumpAndSettle();

              // Test by tooltips
              expect(find.byTooltip('Uncheck shopping item'), findsOneWidget);
            },
          );

          testWidgets(
            'Checks correctly',
            (tester) async {
              shoppingList = ShoppingList(name: 'Test Shopping List');
              final ShoppingItem shoppingItem =
                  ShoppingItem(name: 'Test Shopping Item');
              shoppingList.shoppingItems.add(shoppingItem);

              final Collection collection = Collection(name: 'Test Collection');
              collection.shoppingItemsNames.add('test shopping item');

              setUp(() {
                objectbox.shoppingListBox.put(shoppingList);
                objectbox.collectionBox.put(collection);
              });

              await tester.runAsync(
                () async {
                  await tester.pumpWidget(getShoppingListScreen());
                  await tester.pumpAndSettle();

                  // Test by tooltips
                  expect(find.byTooltip('Check shopping item'), findsOneWidget);

                  // Tap checkbox
                  await tester.tap(find.byTooltip('Check shopping item'));
                  await tester.pumpAndSettle();

                  await Future.delayed(
                    const Duration(seconds: 1),
                    () async {
                      await tester.pumpAndSettle();

                      // Test by tooltips
                      expect(find.byTooltip('Uncheck shopping item'),
                          findsOneWidget);
                    },
                  );
                },
              );
            },
          );

          testWidgets(
            'Unchecks correctly',
            (tester) async {
              shoppingList = ShoppingList(name: 'Test Shopping List');
              final ShoppingItem shoppingItem =
                  ShoppingItem(name: 'Test Shopping Item');
              shoppingItem.checked = true;
              shoppingList.shoppingItems.add(shoppingItem);

              final Collection collection = Collection(name: 'Test Collection');
              collection.shoppingItemsNames.add('test shopping item');

              setUp(() {
                objectbox.shoppingListBox.put(shoppingList);
                objectbox.collectionBox.put(collection);
              });

              await tester.runAsync(
                () async {
                  await tester.pumpWidget(getShoppingListScreen());
                  await tester.pumpAndSettle();

                  // Test by tooltips
                  expect(
                      find.byTooltip('Uncheck shopping item'), findsOneWidget);

                  // Tap checkbox
                  await tester.tap(find.byTooltip('Uncheck shopping item'));
                  await tester.pumpAndSettle();

                  await Future.delayed(
                    const Duration(seconds: 1),
                    () async {
                      await tester.pumpAndSettle();

                      // Test by tooltips
                      expect(find.byTooltip('Check shopping item'),
                          findsOneWidget);
                    },
                  );
                },
              );
            },
          );

          testWidgets(
            'Display initial quantity correctly',
            (tester) async {
              shoppingList = ShoppingList(name: 'Test Shopping List');
              final ShoppingItem shoppingItem =
                  ShoppingItem(name: 'Test Shopping Item');
              shoppingList.shoppingItems.add(shoppingItem);

              final Collection collection = Collection(name: 'Test Collection');
              collection.shoppingItemsNames.add('test shopping item');

              setUp(() {
                objectbox.shoppingListBox.put(shoppingList);
                objectbox.collectionBox.put(collection);
              });

              await tester.pumpWidget(getShoppingListScreen());
              await tester.pumpAndSettle();

              // Test for quantity
              expect(find.text('1'), findsOneWidget);
            },
          );

          testWidgets(
            'Increase quantity',
            (tester) async {
              shoppingList = ShoppingList(name: 'Test Shopping List');
              final ShoppingItem shoppingItem =
                  ShoppingItem(name: 'Test Shopping Item');
              shoppingList.shoppingItems.add(shoppingItem);

              final Collection collection = Collection(name: 'Test Collection');
              collection.shoppingItemsNames.add('test shopping item');

              setUp(() {
                objectbox.shoppingListBox.put(shoppingList);
                objectbox.collectionBox.put(collection);
              });

              await tester.pumpWidget(getShoppingListScreen());
              await tester.pumpAndSettle();

              // Test for initial quantity
              expect(find.text('1'), findsOneWidget);

              // Tap add button
              await tester.tap(find.byTooltip('Increase quantity'));
              await tester.pumpAndSettle();

              // Rebuild StreamBuilder
              await tester.runAsync(
                () async {
                  await Future.delayed(const Duration(seconds: 1));

                  await tester.pumpAndSettle();

                  // Test for new quantity
                  expect(find.text('2'), findsOneWidget);
                },
              );
            },
          );

          testWidgets(
            'Decrease quantity',
            (tester) async {
              shoppingList = ShoppingList(name: 'Test Shopping List');
              final ShoppingItem shoppingItem =
                  ShoppingItem(name: 'Test Shopping Item');
              shoppingList.shoppingItems.add(shoppingItem);

              final Collection collection = Collection(name: 'Test Collection');
              collection.shoppingItemsNames.add('test shopping item');

              setUp(() {
                objectbox.shoppingListBox.put(shoppingList);
                objectbox.collectionBox.put(collection);
              });

              await tester.pumpWidget(getShoppingListScreen());
              await tester.pumpAndSettle();

              // Test for initial quantity
              expect(find.text('1'), findsOneWidget);

              // Tap add button
              await tester.tap(find.byTooltip('Increase quantity'));
              await tester.pumpAndSettle();

              // Rebuild StreamBuilder
              await tester.runAsync(
                () async {
                  await Future.delayed(const Duration(seconds: 1));

                  await tester.pumpAndSettle();

                  // Test for new quantity
                  expect(find.text('2'), findsOneWidget);
                },
              );

              //Tap dec button
              await tester.tap(find.byTooltip('Decrease quantity'));
              await tester.pumpAndSettle();

              // Rebuild StreamBuilder
              await tester.runAsync(
                () async {
                  await Future.delayed(const Duration(seconds: 1));

                  await tester.pumpAndSettle();

                  // Test for new quantity
                  expect(find.text('1'), findsOneWidget);
                },
              );
            },
          );

          testWidgets(
            "Doesn't decrease quantity below 1",
            (tester) async {
              shoppingList = ShoppingList(name: 'Test Shopping List');
              final ShoppingItem shoppingItem =
                  ShoppingItem(name: 'Test Shopping Item');
              shoppingList.shoppingItems.add(shoppingItem);

              final Collection collection = Collection(name: 'Test Collection');
              collection.shoppingItemsNames.add('test shopping item');

              setUp(() {
                objectbox.shoppingListBox.put(shoppingList);
                objectbox.collectionBox.put(collection);
              });

              await tester.pumpWidget(getShoppingListScreen());
              await tester.pumpAndSettle();

              // Test for initial quantity
              expect(find.text('1'), findsOneWidget);

              // Tap dec button
              await tester.tap(find.byTooltip('Decrease quantity'));
              await tester.pumpAndSettle();

              // Rebuild StreamBuilder
              await tester.runAsync(
                () async {
                  await Future.delayed(const Duration(seconds: 1));

                  await tester.pumpAndSettle();

                  // Test for new quantity
                  expect(find.text('1'), findsOneWidget);
                },
              );
            },
          );

          testWidgets(
            'Display options menu',
            (tester) async {
              shoppingList = ShoppingList(name: 'Test Shopping List');
              final ShoppingItem shoppingItem =
                  ShoppingItem(name: 'Test Shopping Item');
              shoppingList.shoppingItems.add(shoppingItem);

              final Collection collection = Collection(name: 'Test Collection');
              collection.shoppingItemsNames.add('test shopping item');

              setUp(() {
                objectbox.shoppingListBox.put(shoppingList);
                objectbox.collectionBox.put(collection);
              });

              await tester.pumpWidget(getShoppingListScreen());
              await tester.pumpAndSettle();

              // Test for options menu
              expect(find.byTooltip('Shopping item options'), findsOneWidget);
            },
          );

          testWidgets(
            'Display delete option in options menu',
            (tester) async {
              shoppingList = ShoppingList(name: 'Test Shopping List');
              final ShoppingItem shoppingItem =
                  ShoppingItem(name: 'Test Shopping Item');
              shoppingList.shoppingItems.add(shoppingItem);

              final Collection collection = Collection(name: 'Test Collection');
              collection.shoppingItemsNames.add('test shopping item');

              setUp(() {
                objectbox.shoppingListBox.put(shoppingList);
                objectbox.collectionBox.put(collection);
              });

              await tester.pumpWidget(getShoppingListScreen());
              await tester.pumpAndSettle();

              // Tap options menu
              await tester.tap(find.byTooltip('Shopping item options'));
              await tester.pumpAndSettle();

              // Test for delete option
              expect(find.text('Delete'), findsOneWidget);
            },
          );

          testWidgets(
            'Delete shopping item from screen when delete option is pressed in options menu',
            (tester) async {
              shoppingList = ShoppingList(name: 'Test Shopping List');
              final ShoppingItem shoppingItem =
                  ShoppingItem(name: 'Test Shopping Item');
              shoppingList.shoppingItems.add(shoppingItem);

              final Collection collection = Collection(name: 'Test Collection');
              collection.shoppingItemsNames.add('test shopping item');

              setUp(() {
                objectbox.shoppingListBox.put(shoppingList);
                objectbox.collectionBox.put(collection);
              });

              await tester.pumpWidget(getShoppingListScreen());
              await tester.pumpAndSettle();

              // Test for shopping item
              expect(find.text(shoppingItem.name), findsOneWidget);

              // Tap options menu
              await tester.tap(find.byTooltip('Shopping item options'));
              await tester.pumpAndSettle();

              // Tap delete option
              await tester.tap(find.text('Delete'));
              await tester.pumpAndSettle();

              await tester.runAsync(
                () async {
                  await Future.delayed(const Duration(seconds: 1));

                  await tester.pumpAndSettle();

                  // Test for shopping item
                  expect(find.text(shoppingItem.name), findsNothing);
                },
              );
            },
          );

          testWidgets(
            'Delete shopping item from storage when delete option is pressed in options menu',
            (tester) async {
              shoppingList = ShoppingList(name: 'Test Shopping List');
              final ShoppingItem shoppingItem =
                  ShoppingItem(name: 'Test Shopping Item');
              shoppingList.shoppingItems.add(shoppingItem);

              final Collection collection = Collection(name: 'Test Collection');
              collection.shoppingItemsNames.add('test shopping item');

              setUp(() {
                objectbox.shoppingListBox.put(shoppingList);
                objectbox.collectionBox.put(collection);
              });

              await tester.pumpWidget(getShoppingListScreen());
              await tester.pumpAndSettle();

              // Test in storage
              expect(objectbox.shoppingItemBox.getAll().length, 1);

              // Tap options menu
              await tester.tap(find.byTooltip('Shopping item options'));
              await tester.pumpAndSettle();

              // Tap delete option
              await tester.tap(find.text('Delete'));
              await tester.pumpAndSettle();

              // Test in storage
              expect(objectbox.shoppingItemBox.getAll().length, 0);
            },
          );

          testWidgets(
            'Remove collection from screen when delete option is pressed in options menu',
            (tester) async {
              shoppingList = ShoppingList(name: 'Test Shopping List');
              final ShoppingItem shoppingItem =
                  ShoppingItem(name: 'Test Shopping Item');
              shoppingList.shoppingItems.add(shoppingItem);

              final Collection collection = Collection(name: 'Test Collection');
              collection.shoppingItemsNames.add('test shopping item');

              setUp(() {
                objectbox.shoppingListBox.put(shoppingList);
                objectbox.collectionBox.put(collection);
              });

              await tester.pumpWidget(getShoppingListScreen());
              await tester.pumpAndSettle();

              // Test for collection
              expect(find.text(collection.name), findsOneWidget);

              // Tap options menu
              await tester.tap(find.byTooltip('Shopping item options'));
              await tester.pumpAndSettle();

              // Tap delete option
              await tester.tap(find.text('Delete'));
              await tester.pumpAndSettle();

              await tester.runAsync(
                () async {
                  await Future.delayed(const Duration(seconds: 1));

                  await tester.pumpAndSettle();

                  // Test for collection
                  expect(find.text(collection.name), findsNothing);
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
