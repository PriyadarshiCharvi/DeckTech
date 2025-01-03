// player_model.dart

import 'package:decktech/models/card_model.dart';

class PlayerModel {
  final String name;
  final bool isHuman;
  int hasBet;
  int stack;
  bool hasFolded;
  bool isAllIn;
  bool actedThisRound;
  List<CardModel> cards;
  bool showCards;
  int position;

  PlayerModel({
    required this.name,
    required this.position,
    this.hasBet = 0,
    this.stack = 100,
    this.hasFolded = false,
    this.isAllIn = false,
    this.isHuman = false,
    this.actedThisRound = false,
    this.cards = const [],
    this.showCards = false,
  });

  void bet(int bet) {
    stack -= bet;
    hasBet += bet;
  }

  void retractPreviousBet() {
    if (actedThisRound) {
      stack += hasBet;
      hasBet = 0;
    }
  }
}