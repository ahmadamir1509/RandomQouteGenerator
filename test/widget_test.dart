import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:random_quote_generator/main.dart';
import 'package:random_quote_generator/providers/quote_controller.dart';
import 'package:random_quote_generator/services/quote_service.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => QuoteController(QuoteService()),
        child: const RandomQuoteApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
