import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_crashcourse/screens/login.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

void main() {
  late LoginPage sut;

  setUp(() {
    sut = LoginPage();
  });

  //tes the content of the login page
  testWidgets('Login page', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: sut));
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Hi, nice to see you !'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'password'), findsOneWidget);
    expect(find.text('No accounts? Sign in'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(
        find.image(AssetImage('assets/images/cyclists.jpg')), findsOneWidget);
  });

  //!!!!!!!!!
  //add tests for a successful login

  //!!!!!!!!!
  //add tests for an unsuccessful login
}
