import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shopping_list_but_free/models/collection.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/widgets/change_collection_name.dart';

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

  Widget getChangeCollectionName(int collectionId) => MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: Scaffold(
          body: SizedBox(
            width: 1000,
            height: 1000,
            child: ChangeCollectionName(collectionId: collectionId),
          ),
        ),
      );

  group(
    'ChangeCollectionName',
    () {
      group(
        'When submitted',
        () {
          testWidgets(
            'Pops screen',
            (tester) async {
              final Collection testCollection =
                  Collection(name: 'Test Collection');

              // Setup
              dbSetUp(() {
                objectbox.collectionBox.put(testCollection);
              });

              await tester
                  .pumpWidget(getChangeCollectionName(testCollection.id));
              await tester.pumpAndSettle();

              // Test for Widget
              expect(find.byType(ChangeCollectionName), findsOneWidget);

              // Submit
              await tester.tap(find.byTooltip('Submit'));
              await tester.pumpAndSettle();

              // Test for Widget
              expect(find.byType(ChangeCollectionName), findsNothing);
            },
          );

          testWidgets(
            'Adds ShoppingList with typed name to db',
            (tester) async {
              final Collection testCollection =
                  Collection(name: 'Test Collection');

              // Setup
              dbSetUp(() {
                objectbox.collectionBox.put(testCollection);
              });

              await tester
                  .pumpWidget(getChangeCollectionName(testCollection.id));
              await tester.pumpAndSettle();

              // Enter new collection name
              await tester.enterText(
                  find.byType(TextFormField).first, 'New Test Collection');
              await tester.pumpAndSettle();

              // Submit
              await tester.tap(find.byTooltip('Submit'));
              await tester.pumpAndSettle();

              // Test for new collection name in db
              expect(objectbox.collectionBox.getAll().first.name,
                  'New Test Collection');
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
