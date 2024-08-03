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

  PlayerModel({
    required this.name,
    this.currentRoundBet = 0,
    this.stack = 500,
    this.hasFolded = false,
    this.isAllIn = false,
    this.isHuman = false,
    this.actedThisRound = false,
    this.cards = const [],
    this.showCards = false,
  });
}