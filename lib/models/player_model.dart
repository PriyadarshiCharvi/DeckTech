// player_model.dart

import 'package:decktech/models/card_model.dart';

class PlayerModel {
  final String name;
  final bool isHuman;
  int currentRoundBet;
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
    this.currentRoundBet = 0,
    this.stack = 100,
    this.hasFolded = false,
    this.isAllIn = false,
    this.isHuman = false,
    this.actedThisRound = false,
    this.cards = const [],
    this.showCards = false,
  });
}