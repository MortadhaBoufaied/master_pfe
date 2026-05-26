
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moez_project/main.dart';

void main() {
  testWidgets('App shell renders for unauthenticated users', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byIcon(Icons.add), findsNothing);
  });
}
