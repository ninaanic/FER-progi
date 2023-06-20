import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:inventura/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('end-to-end test', () {
    testWidgets('Skeniraj i otvori pop up', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      final Finder scan = find.byTooltip('scan');
      await tester.tap(scan);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('Otvaranje dialoga prilikom dodavanja skladišta', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      final Finder addWarehouse = find.byTooltip('addWarehouse');
      await tester.tap(addWarehouse);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('Upisivanje podataka za prijavu', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      final Finder inputEmail = find.byKey(Key('email'));
      final Finder inputPass = find.byKey(Key('inputPass'));
      await tester.enterText(inputEmail, 'fb@gmail.com');
      await tester.enterText(inputPass, '123456');
      expect(find.text('fb@gmail.com'), findsOneWidget);
      expect(find.text('123456'), findsOneWidget);
    });

    testWidgets('Upisivanje podataka za registraciju', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      final Finder inputName = find.byKey(Key('name'));
      final Finder inputLastName = find.byKey(Key('lastName'));
      final Finder inputEmail = find.byKey(Key('email'));
      final Finder inputPass = find.byKey(Key('inputPass'));
      await tester.enterText(inputName, 'Filip');
      await tester.enterText(inputLastName, 'Begović');
      await tester.enterText(inputEmail, 'fb@gmail.com');
      await tester.enterText(inputPass, '123456');
      expect(find.text('Filip'), findsOneWidget);
      expect(find.text('Begović'), findsOneWidget);
      expect(find.text('fb@gmail.com'), findsOneWidget);
      expect(find.text('123456'), findsOneWidget);
    });
  });
}
