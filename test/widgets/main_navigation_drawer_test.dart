import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shopping_list_but_free/objectbox.dart';
import 'package:shopping_list_but_free/screens/about_screen.dart';
import 'package:shopping_list_but_free/screens/collections_screen.dart';
import 'package:shopping_list_but_free/screens/home_screen.dart';
import 'package:shopping_list_but_free/widgets/main_navigation_drawer.dart';

void main() async {
  // Initialize objectbox
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  objectbox = await ObjectBox.open();

  Widget getMainNavigationDrawer() => MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const Scaffold(
          drawer: MainNavigationDrawer(),
          body: SizedBox(
            width: 1000,
            height: 1000,
          ),
        ),
      );

  group(
    'MainNavigationDrawer',
    () {
      testWidgets(
        'Displays title',
        (tester) async {
          await tester.pumpWidget(getMainNavigationDrawer());
          await tester.pumpAndSettle();

          // Drag Drawer
          await tester.dragFrom(const Offset(10, 500), const Offset(500, 500));
          await tester.pumpAndSettle();

          // Test for title
          expect(find.text('Navigation Menu'), findsOneWidget);
        },
      );

      testWidgets(
        'Displays correct items',
        (tester) async {
          await tester.pumpWidget(getMainNavigationDrawer());
          await tester.pumpAndSettle();

          // Drag Drawer
          await tester.dragFrom(const Offset(10, 500), const Offset(500, 500));
          await tester.pumpAndSettle();

          // Test for items
          expect(find.text('Home'), findsOneWidget);
          expect(find.text('Collections'), findsOneWidget);
          expect(find.text('About'), findsOneWidget);
          expect(find.text('Source Code'), findsOneWidget);
        },
      );

      testWidgets(
        'Tapping Home pushes HomeScreen',
        (tester) async {
          await tester.pumpWidget(getMainNavigationDrawer());
          await tester.pumpAndSettle();

          // Drag Drawer
          await tester.dragFrom(const Offset(10, 500), const Offset(500, 500));
          await tester.pumpAndSettle();

          // Test for HomeScreen
          expect(find.byType(HomeScreen), findsNothing);

          // Tap Home tile
          await tester.tap(find.text('Home'));
          await tester.pumpAndSettle();

          // Test for HomeScreen
          expect(find.byType(HomeScreen), findsOneWidget);
        },
      );

      testWidgets(
        'Tapping Collections pushes CollectionsScreen',
        (tester) async {
          await tester.pumpWidget(getMainNavigationDrawer());
          await tester.pumpAndSettle();

          // Drag Drawer
          await tester.dragFrom(const Offset(10, 500), const Offset(500, 500));
          await tester.pumpAndSettle();

          // Test for CollectionsScreen
          expect(find.byType(CollectionsScreen), findsNothing);

          // Tap Collections tile
          await tester.tap(find.text('Collections'));
          await tester.pumpAndSettle();

          // Test for CollectionsScreen
          expect(find.byType(CollectionsScreen), findsOneWidget);
        },
      );

      testWidgets(
        'Tapping About pushes AboutScreen',
        (tester) async {
          await tester.pumpWidget(getMainNavigationDrawer());
          await tester.pumpAndSettle();

          // Drag Drawer
          await tester.dragFrom(const Offset(10, 500), const Offset(500, 500));
          await tester.pumpAndSettle();

          // Test for AboutScreen
          expect(find.byType(AboutScreen), findsNothing);

          // Tap About tile
          await tester.tap(find.text('About'));
          await tester.pumpAndSettle();

          // Test for AboutScreen
          expect(find.byType(AboutScreen), findsOneWidget);
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
