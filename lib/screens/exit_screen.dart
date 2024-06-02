import 'package:decktech/screens/routes.dart';
import 'package:flutter/material.dart';


class ExitScreen extends StatelessWidget {
  const ExitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 130, 37, 37),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),

              const Text(
                "LOGGED OUT",
                style: TextStyle(
                  color: Color.fromARGB(255, 208, 135, 135),
                  fontSize: 20,
                  fontWeight: FontWeight.bold)
              ),

              const SizedBox(
                height: 30,
              ),

              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.portrait);
                  },
                  child: Container(
                    color: const Color.fromARGB(255, 158, 110, 110),
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(color: Colors.white, fontSize: 13.0),
                    ),
                  ),
                ),

              
            ],

          )
        )
      ),
    );
  }
}