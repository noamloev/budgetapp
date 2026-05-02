import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:budget/app/app.dart';

void main() {
  testWidgets('app renders', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const BudgetApp());
    await tester.pumpAndSettle();

    expect(find.byType(Scaffold), findsOneWidget);
  });
}
