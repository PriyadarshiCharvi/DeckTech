import 'package:decktech/screens/deck_service.dart';
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
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 130, 37, 37),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 50),

              Text(
                "POKER TABLE",
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