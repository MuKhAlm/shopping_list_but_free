import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shopping_list_but_free/models/shopping_list.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/widgets/export_shopping_list.dart';

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

  Widget getExportShoppingList(ShoppingList shoppingList) => MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: ExportShoppingList(shoppingList: shoppingList),
      );

  group(
    'ExportShoppingList',
    () {
      testWidgets(
        'Displays title',
        (tester) async {
          ShoppingList testShoppingList =
              ShoppingList(name: 'Test Shopping List');
          // Setup
          dbSetUp();

          await tester.pumpWidget(getExportShoppingList(testShoppingList));
          await tester.pumpAndSettle();

          // Test for title
          expect(
              find.text('Share the shopping list code for others to import it'),
              findsOneWidget);
        },
      );

      testWidgets(
        'Displays copy button',
        (tester) async {
          ShoppingList testShoppingList =
              ShoppingList(name: 'Test Shopping List');
          // Setup
          dbSetUp();

          await tester.pumpWidget(getExportShoppingList(testShoppingList));
          await tester.pumpAndSettle();

          // Test for text
          expect(find.text('Shopping list code'), findsOneWidget);
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
