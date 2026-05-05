import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habitly/features/auth/presentation/pages/register_page.dart';

void main() {
  group('RegisterPage', () {
    testWidgets('shows nickname, email and password fields', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
      
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('Никнейм'), findsOneWidget);
      expect(find.text('Email *'), findsOneWidget);
      expect(find.text('Пароль *'), findsOneWidget);
    });

    testWidgets('shows validation errors for empty required fields', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
      
      await tester.tap(find.text('Зарегистрироваться'));
      await tester.pump();
      
      expect(find.text('Введите email'), findsOneWidget);
      expect(find.text('Минимум 6 символов'), findsOneWidget);
    });

    testWidgets('shows error for short nickname', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
      
      await tester.enterText(find.byType(TextFormField).first, 'ab');
      await tester.tap(find.text('Зарегистрироваться'));
      await tester.pump();
      
      expect(find.text('Минимум 3 символа'), findsOneWidget);
    });

    testWidgets('does not show error for empty nickname (optional)', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
      
      await tester.enterText(find.byType(TextFormField).at(1), 'test@mail.com');
      await tester.enterText(find.byType(TextFormField).last, '123456');
      await tester.pump();
      
      expect(find.text('Минимум 3 символа'), findsNothing);
    });

    testWidgets('navigates back to login when "Уже есть аккаунт?" tapped', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterPage()));
      
      await tester.tap(find.text('Уже есть аккаунт? Войти'));
      await tester.pumpAndSettle();
      
      expect(find.byType(RegisterPage), findsNothing);
    });
  });
}