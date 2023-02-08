import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/objectbox.g.dart';
import 'package:shopping_list_but_free/widgets/add_shopping_list.dart';

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

  Widget getAddShoppingList() => MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const Scaffold(
          body: SizedBox(
            width: 1000,
            height: 1000,
            child: AddShoppingList(),
          ),
        ),
      );

  group(
    'AddShoppingList',
    () {
      testWidgets(
        'Pops when back arrow is pressed',
        (tester) async {
          // Setup
          dbSetUp();

          await tester.pumpWidget(getAddShoppingList());
          await tester.pumpAndSettle();

          // Test for AddShoppingList
          expect(find.byType(AddShoppingList), findsOneWidget);

          // Tap back arrow
          await tester.tap(find.byTooltip('Back'));
          await tester.pumpAndSettle();

          // Test for AddShoppingList
          expect(find.byType(AddShoppingList), findsNothing);
        },
      );

      testWidgets(
        'Displays a text field',
        (tester) async {
          // Setup
          dbSetUp(() {});

          await tester.pumpWidget(getAddShoppingList());
          await tester.pumpAndSettle();

          // Test for TextFormField
          expect(find.byType(TextFormField), findsOneWidget);
        },
      );

      testWidgets(
        'Displays a submit button',
        (tester) async {
          // Setup
          dbSetUp(() {});

          await tester.pumpWidget(getAddShoppingList());
          await tester.pumpAndSettle();

          // Test for submit button
          expect(find.byTooltip('Submit'), findsOneWidget);
        },
      );

      group(
        'When submitted',
        () {
          testWidgets(
            'Adds Collection with typed name to db',
            (tester) async {
              // Setup
              dbSetUp(() {});

              await tester.pumpWidget(getAddShoppingList());
              await tester.pumpAndSettle();

              // Enter new collection name
              await tester.enterText(
                  find.byType(TextFormField).first, 'New Test Shopping List');
              await tester.pumpAndSettle();

              // Submit
              await tester.tap(find.byTooltip('Submit'));
              await tester.pumpAndSettle();

              // Test for new Collection in db
              expect(
                  objectbox.shoppingListBox
                          .query(ShoppingList_.name
                              .equals('New Test Shopping List'))
                          .build()
                          .findFirst() !=
                      null,
                  true);
            },
          );

          testWidgets(
            'Adds Collection with typed name to db',
            (tester) async {
              // Setup
              dbSetUp(() {});

              await tester.pumpWidget(getAddShoppingList());
              await tester.pumpAndSettle();

              // Enter new collection name
              await tester.enterText(
                  find.byType(TextFormField).first, 'New Test Shopping List');
              await tester.pumpAndSettle();

              // Test for AddShoppingList
              expect(find.byType(AddShoppingList), findsOneWidget);

              // Submit
              await tester.tap(find.byTooltip('Submit'));
              await tester.pumpAndSettle();

              // Test for AddShoppingList
              expect(find.byType(AddShoppingList), findsNothing);
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
