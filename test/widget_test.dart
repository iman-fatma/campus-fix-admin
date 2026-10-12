// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_fix_admin/main.dart';
import 'package:campus_fix_admin/widgets/stat_metric_card.dart';

void main() {
  testWidgets('Firebase initialization failure is visible', (tester) async {
    await tester.pumpWidget(
      const CampusFixAdminApp(firebaseError: 'Firebase config error'),
    );

    expect(find.text('Could not connect to Firebase'), findsOneWidget);
    expect(find.text('Firebase config error'), findsOneWidget);
  });

  testWidgets('dashboard metric card fits a phone-sized grid cell', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 150,
              height: 160,
              child: StatMetricCard(
                title: 'Open / Pending',
                value: '128',
                icon: Icons.pending_actions_rounded,
                iconColor: Colors.blue,
                iconBgColor: Colors.white,
                subtitle: 'Awaiting technician assignment',
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
