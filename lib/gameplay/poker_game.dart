// poker_game.dart

// ignore_for_file: avoid_print

import 'package:decktech/models/card_model.dart';
import 'package:decktech/models/deck_model.dart';
import 'package:decktech/models/draw_model.dart';
import 'package:decktech/models/player_model.dart';
import 'package:decktech/screens/deck_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

class PokerGame {
  List<PlayerModel> players = [];
  late DeckService deckService;
  late DeckModel deck;
  List<CardModel> communityCards = [];
  int currentPlayerIndex = 0;
  int potValue = 0;
  int revealState = 0;
  int prevBet = 0;

  PokerGame() {
    deckService = DeckService();
    players = [];
  }

  Future<void> startGame() async {
    try {
      print("Fetching new deck...");
      deck = await deckService.newDeck();
      print("Deck fetched: ${deck.deck_id}");

      for (PlayerModel player in players) {
        print("Drawing cards for player ${player.name}...");
        DrawModel draw = await deckService.drawCards(deck, count: 2);
        player.cards = draw.cards;
        print("Player ${player.name} hand: ${player.cards.map((card) => card.image).join(', ')}");
      }

      print("Drawing community cards...");
      DrawModel draw = await deckService.drawCards(deck, count: 5);
      communityCards = draw.cards;

      if (kDebugMode) {
        print("Community cards: ${communityCards.map((card) => card.image).join(', ')}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error in startGame: $e");
      }
      // Handle errors as needed
    }
  }

  //Next player action handler
  void nextPlayer() {
    if (bettingRoundComplete()) {
      roundEnd();
    }
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    if (currentPlayerIndex != 0) {
      computerActions();
    } else {
      if (players[0].hasFolded == true) {
        nextPlayer();
      }
      print("------ACTION ON YOU------");
      return;
    }
  }

  //Check if betting round is complete
  bool bettingRoundComplete() {
    var standard = 0;
    for (var i = 0; i < 4; i++) {
      if (!players[i].hasFolded && !players[i].isAllIn) {
        standard = players[i].currentRoundBet;
        break;
      }
    }
    for (var i = 0; i < 4; i++) {
      if (!players[i].actedThisRound || ((!players[i].hasFolded) && players[i].currentRoundBet != standard && !players[i].isAllIn)) {
        return false;
      }
    }
    return true;
  }

  // Round end
  Future<void> roundEnd() async{
      for (int i = 0; i < 4; i++) {
        players[i].currentRoundBet = 0;
        players[i].actedThisRound = false;
      }
      prevBet = 0;
      print("------BETTING ROUND COMPLETE------");
      print("------PRESS ARROW ON TOP RIGHT------");
      return;
  }

  // Player action: Raise by 50
  Future<void> raiseS() async{
    int betAmount = 50 + prevBet;
    if (betAmount <= players[currentPlayerIndex].stack) {
      players[currentPlayerIndex].actedThisRound = true;
      potValue += betAmount - players[currentPlayerIndex].currentRoundBet;
      players[currentPlayerIndex].stack -= betAmount - players[currentPlayerIndex].currentRoundBet;
      players[currentPlayerIndex].currentRoundBet = betAmount;
      prevBet += 50;
      print("${players[currentPlayerIndex].name} raise 50");
      print("${players[currentPlayerIndex].name} current round bet: ${players[currentPlayerIndex].currentRoundBet}");
      print("${players[currentPlayerIndex].name} stack: ${players[currentPlayerIndex].stack}");
      print("Pot: $potValue");
      nextPlayer();
    } else {
      print("Cannot Raise 50");
    }
  }

  // Player action: Raise by 150
  Future<void> raiseP() async{
    int betAmount = 150 + prevBet;
    if (betAmount <= players[currentPlayerIndex].stack) {
      players[currentPlayerIndex].actedThisRound = true;
      potValue += betAmount - players[currentPlayerIndex].currentRoundBet;
      players[currentPlayerIndex].stack -= betAmount - players[currentPlayerIndex].currentRoundBet;
      players[currentPlayerIndex].currentRoundBet = betAmount;
      prevBet += 150;
      print("${players[currentPlayerIndex].name} raise 150");
      print("${players[currentPlayerIndex].name} current round bet: ${players[currentPlayerIndex].currentRoundBet}");
      print("${players[currentPlayerIndex].name} stack: ${players[currentPlayerIndex].stack}");
      print("Pot: $potValue");
      nextPlayer();
    } else {
      print("Cannot Raise 150");
    }
  }

  // Player action: All in
  Future<void> raiseA() async{
    int betAmount = players[currentPlayerIndex].stack;
    players[currentPlayerIndex].actedThisRound = true;
    players[currentPlayerIndex].stack = 0;
    players[currentPlayerIndex].isAllIn = true;
    players[currentPlayerIndex].currentRoundBet += betAmount;
    potValue += betAmount;
    if (betAmount > prevBet) {
      prevBet = betAmount;
    }
    print("${players[currentPlayerIndex].name} all in");
    print("${players[currentPlayerIndex].name} current round bet: ${players[currentPlayerIndex].currentRoundBet}");
    print("${players[currentPlayerIndex].name} stack: ${players[currentPlayerIndex].stack}");
    print("Pot: $potValue");
    nextPlayer();
  }

  // Player action: Call
  Future<void> call() async{
    if (prevBet <= players[currentPlayerIndex].stack) {
      players[currentPlayerIndex].actedThisRound = true;
      potValue += prevBet - players[currentPlayerIndex].currentRoundBet;
      players[currentPlayerIndex].stack -= prevBet - players[currentPlayerIndex].currentRoundBet;
      players[currentPlayerIndex].currentRoundBet = prevBet;
      print("${players[currentPlayerIndex].name} call");
      print("${players[currentPlayerIndex].name} current round bet: ${players[currentPlayerIndex].currentRoundBet}");
      print("${players[currentPlayerIndex].name} stack: ${players[currentPlayerIndex].stack}");
      print("Pot: $potValue");
      nextPlayer();
    } else {
      print("Cannot Call");
    }
  }

  // Player action: Check
  Future<void> check() async{
    if (prevBet == 0) {
      players[currentPlayerIndex].actedThisRound = true;
      print("${players[currentPlayerIndex].name} check");
      print("${players[currentPlayerIndex].name} current round bet: ${players[currentPlayerIndex].currentRoundBet}");
      print("${players[currentPlayerIndex].name} stack: ${players[currentPlayerIndex].stack}");
      print("Pot: $potValue");
      nextPlayer();
    } else {
      print("Cannot Check");
    }
  }

  // Player action: Fold
  Future<void> fold() async{
    players[currentPlayerIndex].actedThisRound = true;
    players[currentPlayerIndex].hasFolded = true;
    print("${players[currentPlayerIndex].name} fold");
    print("${players[currentPlayerIndex].name} current round bet: ${players[currentPlayerIndex].currentRoundBet}");
    players[currentPlayerIndex].currentRoundBet = prevBet;
    print("${players[currentPlayerIndex].name} stack: ${players[currentPlayerIndex].stack}");
    print("Pot: $potValue");
    nextPlayer();
  }

  //Initialize random number generator
  int random(int min, int max) {
    return min + Random().nextInt(max - min);
  }

  //Computer action
  Future<void> computerActions() async{
    print("------${players[currentPlayerIndex].name} Action------");
    if (players[currentPlayerIndex].hasFolded == true) {
      nextPlayer();
    }
    var rand = random(0, 2);
    if (rand == 0) {
      call();
    } else if (rand == 1) {
      raiseS();
    }
  }
}