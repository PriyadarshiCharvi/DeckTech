import 'package:decktech/screens/deck_service.dart';
import 'package:decktech/screens/exit_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    tempFunc();
  }

  void tempFunc() async {
    final service = DeckService();
    final deck = await service.newDeck();

    if (kDebugMode) {
      print(deck.remaining);
    }
    if (kDebugMode) {
      print('-----');
    }
    final draw = await service.drawCards(deck, count: 7);
    if (kDebugMode) {
      print(draw.cards.length);
    }
    if (kDebugMode) {
      print('=======');
    }
    if (kDebugMode) {
      print(draw.remaining);
    }
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 130, 37, 37),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/backdrop.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),

              const Text(
                "POKER TABLE",
                style: TextStyle(
                  color: Color.fromARGB(255, 208, 135, 135),
                  fontSize: 20,
                  fontWeight: FontWeight.bold)
              ),

              const SizedBox(
                height: 30,
              ),

              
              const BackButton(),

              const SizedBox(
                height: 50,
              ),

              TextButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                   Navigator.push(context, MaterialPageRoute(builder: (context) => const ExitScreen()));
                  },
                  child: Container(
                    color: const Color.fromARGB(255, 158, 110, 110),
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white, fontSize: 13.0),
                    ),
                  ),
                ),



              

              
            ],

          )
        ),
      ),
    );
  }
}