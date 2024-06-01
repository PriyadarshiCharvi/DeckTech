import 'package:flutter/material.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 130, 37, 37),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 50),

              Text(
                "LOGGED IN",
                style: TextStyle(
                  color: Color.fromARGB(255, 208, 135, 135),
                  fontSize: 20,
                  fontWeight: FontWeight.bold)
              ),

              SizedBox(
                height: 30,
              ),

              

              BackButton(),

              
            ],

          )
        )
      ),
    );
  }
}