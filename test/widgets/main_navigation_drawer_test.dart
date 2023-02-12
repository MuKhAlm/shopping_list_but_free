import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list_but_free/widgets/main_navigation_drawer.dart';

void main() async {
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

  group('MainNavigationDrawer', () {
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
  });
}
