import 'package:decktech/screens/login_screen.dart';
import 'package:flutter/material.dart';
import '../components/back_button.dart'

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const Text("LOGGED IN"),

              const SizedBox(
                height: 30,
              ),

              BackButton(
                onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()))
                },
              )
            ],

          )
        )
      ),
    );
  }
}