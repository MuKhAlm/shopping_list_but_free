import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shopping_list_but_free/screens/home_screen.dart';

void main() {
  group('HomeScreen', () {
    group('static', () {
      testWidgets('Display navigation menu', (tester) async {
        await tester.pumpWidget(getHomeScreen());
        expect(find.byTooltip('Open navigation menu'), findsOneWidget);
      });

      testWidgets('Dispaly shopping list adding button', (tester) async {
        await tester.pumpWidget(getHomeScreen());
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('Display correct title', (tester) async {
        await tester.pumpWidget(getHomeScreen());
        expect(find.text('Shopping List But Free'), findsOneWidget);
      });
    });
  });
}

Widget getHomeScreen() => const MaterialApp(home: HomeScreen());
