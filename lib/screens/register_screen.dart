// import 'package:auth/auth.dart';
import 'package:decktech/components/my_textfield.dart';
import 'package:decktech/components/signup_button.dart';
import 'package:decktech/screens/routes.dart';
import 'package:flutter/material.dart';
import '../components/square_tile.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

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
              
              const SizedBox(height: 20),

              const Text(
                'Register',
                style: TextStyle(
                  color: Color.fromARGB(255, 208, 135, 135),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

             const SizedBox(height: 25),

             MyTextfield(
              controller: usernameController,
              hintText: 'Username',
              obscureText: false,
             ),

             const SizedBox(height: 10),

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

             const SizedBox(height: 20),

             /* const Padding(
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
             ), */

             // const SizedBox(height: 20),

             /* TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                  },
                  child: Container(
                    color: const Color.fromARGB(255, 158, 110, 110),
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.white, fontSize: 13.0),
                    ),
                  ),
                ), */

              SignupButton(
              onTap: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                Navigator.pushNamed(context, AppRoutes.landscape);
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

              const SizedBox(height: 30),

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

              const SizedBox(height: 30),

              const BackButton(),

              /* Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Not a member?',
                    style: TextStyle(color: Color.fromARGB(255, 29, 28, 28)),
                  ),
                  const SizedBox(width: 4),

                  /* Text(
                    'Register now',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ), */

                  GestureDetector(
                    onTap: () {
                    },
                    child: const Text('Clickable Text Using GestureDetector'),
                     ),
                ],
              ) */

            
            ],
          )
        )
      )
    );

  }
}