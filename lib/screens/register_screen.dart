
import 'package:decktech/components/my_textfield.dart';
import 'package:decktech/components/signup_button.dart';
import 'package:decktech/screens/login_screen.dart';
import 'package:decktech/screens/routes.dart';
import 'package:decktech/services/firebase_auth_implementation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../components/square_tile.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();

}

  /* final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  void signUserIn() {

  }  */
class _RegisterScreenState extends State<RegisterScreen> {

  final FirebaseAuthImplementation _auth = FirebaseAuthImplementation();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
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
                'Register',
                style: TextStyle(
                  color: Color.fromARGB(255, 208, 135, 135),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

             const SizedBox(height: 25),

             MyTextfield(
              controller: _usernameController,
              hintText: 'Username',
              obscureText: false,
             ),

             const SizedBox(height: 10),

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
              onTap: _register,
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

  void _register() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    if (user != null) {
      if (kDebugMode) {
        print("User is successfully created");
      }
      Navigator.pushNamed(context, "/portrait");
    } else {
      if (kDebugMode) {
        print("Some error occurred");
      }
    }
  }
}