import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitly/features/auth/presentation/pages/login_page.dart';

void main() {
  group('LoginPage', () {
    testWidgets('shows email and password fields', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email *'), findsOneWidget);
      expect(find.text('Пароль *'), findsOneWidget);
    });

    testWidgets('shows validation errors for empty fields', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      
      await tester.tap(find.text('Войти'));
      await tester.pump();
      
      expect(find.text('Введите email'), findsOneWidget);
      expect(find.text('Минимум 6 символов'), findsOneWidget);
    });

    testWidgets('shows error for invalid email', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      
      await tester.enterText(find.byType(TextFormField).first, 'invalid');
      await tester.tap(find.text('Войти'));
      await tester.pump();
      
      expect(find.text('Неверный формат email'), findsOneWidget);
    });

    testWidgets('button is enabled even when fields are empty', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('button is enabled when fields are filled', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));
      
      await tester.enterText(find.byType(TextFormField).first, 'test@mail.com');
      await tester.enterText(find.byType(TextFormField).last, '123456');
      await tester.pump();
      
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNotNull);
    });
  });
}