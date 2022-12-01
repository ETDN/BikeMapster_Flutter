import 'dart:math';
import 'package:flutter_crashcourse/screens/register.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crashcourse/screens/login.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late LoginPage loginPage;

  setUp(() {
    loginPage = LoginPage();
  });

  //tes the content of the login page
  testWidgets('Login page', (WidgetTester tester) async {
    final mockObserver = MockNavigatorObserver();
    await tester.pumpWidget(MaterialApp(
      home: loginPage,
      navigatorObservers: [mockObserver],
    ));

    expect(find.widgetWithText(TextFormField, 'email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'password'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

    //find image with content
    expect(find.byWidgetPredicate((widget) {
      if (widget is Image) {
        return widget.image.toString().contains('assets/images/pin_logo.png');
      }
      return false;
    }), findsOneWidget);

    //test navigation to register page
    await tester.tap(find.byWidgetPredicate((Widget widget) =>
        widget is RichText &&
        widget.text.toPlainText() == "No account ? Sign in"));
    await tester.pumpAndSettle();
    expect(find.byType(Register), findsOneWidget);
  });

  //!!!!!!!!!
  //add tests for a successful login

  //!!!!!!!!!
  //add tests for an unsuccessful login

  //test the map page
}
