import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shopping_list_but_free/models/collection.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/widgets/add_shopping_item_name.dart';

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

  Widget getAddShoppingItemName(int collectionId) => MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: Scaffold(
          body: SizedBox(
            width: 1000,
            height: 1000,
            child: AddShoppingItemName(collectionId: collectionId),
          ),
        ),
      );

  group(
    'AddShoppingList',
    () {
      group(
        'When submitted',
        () {
          testWidgets(
            'Pops screen',
            (tester) async {
              final testCollection = Collection(name: 'Test Collection');

              // Setup
              dbSetUp(() {
                objectbox.collectionBox.put(testCollection);
              });

              await tester
                  .pumpWidget(getAddShoppingItemName(testCollection.id));
              await tester.pumpAndSettle();

              // Test for Widget
              expect(find.byType(AddShoppingItemName), findsOneWidget);

              // Submit
              await tester.tap(find.byTooltip('Submit'));
              await tester.pumpAndSettle();

              // Test for Widget
              expect(find.byType(AddShoppingItemName), findsNothing);
            },
          );

          testWidgets(
            'Adds ShoppingList with typed name to db',
            (tester) async {
              final testCollection = Collection(name: 'Test Collection');

              // Setup
              dbSetUp(() {
                objectbox.collectionBox.put(testCollection);
              });

              await tester
                  .pumpWidget(getAddShoppingItemName(testCollection.id));
              await tester.pumpAndSettle();

              // Enter new shopping item name
              await tester.enterText(
                  find.byType(TextFormField).first, 'new test shopping item');
              await tester.pumpAndSettle();

              // Submit
              await tester.tap(find.byTooltip('Submit'));
              await tester.pumpAndSettle();

              // Test for Collection in db
              expect(
                  objectbox.collectionBox
                      .get(testCollection.id)!
                      .shoppingItemsNames[0],
                  'new test shopping item');
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
