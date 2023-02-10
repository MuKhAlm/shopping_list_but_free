import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/widgets/add_entity.dart';

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

  Widget getAddShoppingList(void Function(String) onSubmit) => MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: Scaffold(
          body: SizedBox(
            width: 1000,
            height: 1000,
            child: AddEntity(onSubmit: onSubmit),
          ),
        ),
      );

  group(
    'AddEntity',
    () {
      testWidgets(
        'Pops when back arrow is pressed',
        (tester) async {
          // Setup
          dbSetUp();

          await tester.pumpWidget(getAddShoppingList((value) {}));
          await tester.pumpAndSettle();

          // Test for AddShoppingList
          expect(find.byType(AddEntity), findsOneWidget);

          // Tap back arrow
          await tester.tap(find.byTooltip('Back'));
          await tester.pumpAndSettle();

          // Test for AddShoppingList
          expect(find.byType(AddEntity), findsNothing);
        },
      );

      testWidgets(
        'Displays a text field',
        (tester) async {
          // Setup
          dbSetUp(() {});

          await tester.pumpWidget(getAddShoppingList((value) {}));
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

          await tester.pumpWidget(getAddShoppingList((value) {}));
          await tester.pumpAndSettle();

          // Test for submit button
          expect(find.byTooltip('Submit'), findsOneWidget);
        },
      );

      testWidgets(
        'Invokes onSubmit when submitted',
        (tester) async {
          int timesCalled = 0;
          void onSubmit(String value) {
            timesCalled++;
          }

          // Setup
          dbSetUp(() {});

          await tester.pumpWidget(getAddShoppingList(onSubmit));
          await tester.pumpAndSettle();

          // Test for onSubmit invoke
          expect(timesCalled, 0);

          // Submit
          await tester.tap(find.byTooltip('Submit'));
          await tester.pumpAndSettle();

          // Test for onSubmit invoke
          expect(timesCalled, 1);
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
