// player_model.dart

import 'package:decktech/models/card_model.dart';

class PlayerModel {
  final String name;
  final bool isHuman;
  var currentRoundBet;
  var stack;
  var hasFolded;
  var isAllIn;
  var actedThisRound;
  List<CardModel> cards;

  PlayerModel({
    required this.name,
    this.currentRoundBet = 0,
    this.stack = 500,
    this.hasFolded = false,
    this.isAllIn = false,
    this.isHuman = false,
    this.actedThisRound = false,
    this.cards = const [],
  });
}