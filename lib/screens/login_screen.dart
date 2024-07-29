import 'package:decktech/components/my_textfield.dart';
import 'package:decktech/screens/register_screen.dart';
import 'package:decktech/screens/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../components/my_button.dart';
import '../components/square_tile.dart';
import '../services/firebase_auth_implementation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final FirebaseAuthImplementation _auth = FirebaseAuthImplementation();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 130, 37, 37),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),

              const Icon(
                Icons.gamepad,
                size: 100,
              ),
              
              const SizedBox(height: 20),

              const Text(
                'DeckTech',
                style: TextStyle(
                  color: Color.fromARGB(255, 208, 135, 135),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

             const SizedBox(height: 25),

             MyTextfield(
              controller: _emailController,
              hintText: 'Email',
              obscureText: false,
             ),

             const SizedBox(height: 10),

             MyTextfield(
              controller: _passwordController,
              hintText: 'Password',
              obscureText: true,
             ),

             const SizedBox(height: 20),

             MyButton(
              onTap: () {
                _login();
               },
             ),

             const SizedBox(height: 30),

             
             Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ]
                )
             ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Not a member?',
                    style: TextStyle(color: Color.fromARGB(255, 29, 28, 28), fontSize: 20),
                  ),
                  const SizedBox(width: 4),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        fontSize: 20

                      ),
                      ),
                    
                     ),
                ],
              )

            
            ],
          )
        )
      )
    );

  }

  void _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    if (user != null) {
      if (kDebugMode) {
        print("User is successfully logged in");
      }
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, AppRoutes.landscape);
    } else {
      if (kDebugMode) {
        print("Wrong email/password");
      }
      // ignore: use_build_context_synchronously
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }
}