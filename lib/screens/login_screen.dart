// import 'package:auth/auth.dart';
import 'package:decktech/components/my_textfield.dart';
import 'package:decktech/screens/routes.dart';
import 'package:flutter/material.dart';
import '../components/my_button.dart';
import '../components/square_tile.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() {
    /* await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text, 
      password: passwordController.text,
      ); */

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
              
              const SizedBox(height: 40),

              const Text(
                'Welcome to DeckTech',
                style: TextStyle(
                  color: Color.fromARGB(255, 208, 135, 135),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

             const SizedBox(height: 25),

             MyTextfield(
              controller: emailController,
              hintText: 'Email',
              obscureText: false,
             ),

             const SizedBox(height: 10),

             MyTextfield(
              controller: passwordController,
              hintText: 'Password',
              obscureText: true,
             ),

             const SizedBox(height: 10),

             const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Forgot Password?',
                    style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ],
              ),
             ),

             const SizedBox(height: 20),

             MyButton(
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                Navigator.pushNamed(context, AppRoutes.landscape);
              },
             ),

             const SizedBox(height: 45),

             
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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(color: Color.fromARGB(255, 25, 22, 22)),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Color.fromRGBO(189, 189, 189, 1),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 45),

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // google button
                  SquareTile(imagePath: 'lib/icons/google.png'),

                  SizedBox(width: 25),

                  // apple button
                  SquareTile(imagePath: 'lib/icons/apple.png')
                ],
              ),

              const SizedBox(height: 45),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not a member?',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Register now',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
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
}