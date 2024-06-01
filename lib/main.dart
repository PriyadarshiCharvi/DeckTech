// import 'package:decktech/screens/auth_page.dart';
// ignore: unused_import
import 'package:decktech/screens/login_screen.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

void main() {
  /* WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); */
  runApp(const DeckTech());
}

class DeckTech extends StatelessWidget {
  const DeckTech({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }

}
