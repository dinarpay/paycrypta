import 'package:flutter/material.dart';
import 'package:paycrypta/screens/main_screen.dart';
import 'package:paycrypta/screens/send_screen.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/registration_screen.dart';

void main() => runApp(PayCrypta());

class PayCrypta extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        MainScreen.id: (context) => MainScreen(),
        SendScreen.id: (context) => SendScreen(),
      },
    );
  }
}
