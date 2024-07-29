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

  void nextPlayer() {
    if (bettingRoundComplete()) {
      roundEnd();
    }
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    if (currentPlayerIndex != 0) {
      computerActions();
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
      print("Betting round complete");
      return;
  }

  // Player action: Raise by 50
  Future<void> raiseS() async{
    int raiseAmount = 50 + prevBet;
    if (raiseAmount <= players[currentPlayerIndex].stack) {
      players[currentPlayerIndex].actedThisRound = true;
      players[currentPlayerIndex].stack -= raiseAmount;
      players[currentPlayerIndex].currentRoundBet += raiseAmount;
      potValue += raiseAmount;
      prevBet += 50;
      print(players[currentPlayerIndex].name);
      print("currentRoundBet: ${players[currentPlayerIndex].currentRoundBet}");
      print("stack: ${players[currentPlayerIndex].stack}");
      print("potValue: $potValue");
      nextPlayer();
    } else {
    }
  }

  // Player action: Raise by 150
  Future<void> raiseP() async{
    int raiseAmount = 150 + prevBet;
    if (raiseAmount <= players[currentPlayerIndex].stack) {
      players[currentPlayerIndex].actedThisRound = true;
      players[currentPlayerIndex].stack -= raiseAmount;
      players[currentPlayerIndex].currentRoundBet += raiseAmount;
      potValue += raiseAmount;
      prevBet += 150;
      print(players[currentPlayerIndex].name);
      print("currentRoundBet: ${players[currentPlayerIndex].currentRoundBet}");
      print("stack: ${players[currentPlayerIndex].stack}");
      print("potValue: $potValue");
      nextPlayer();
    } else {
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
    print(players[currentPlayerIndex].name);
    print("currentRoundBet: ${players[currentPlayerIndex].currentRoundBet}");
    print("stack: ${players[currentPlayerIndex].stack}");
    print("potValue: $potValue");
    nextPlayer();
  }

  // Player action: Call
  Future<void> call() async{
    if (prevBet <= players[currentPlayerIndex].stack) {
      players[currentPlayerIndex].actedThisRound = true;
      players[currentPlayerIndex].stack -= prevBet;
      players[currentPlayerIndex].currentRoundBet += prevBet;
      potValue += prevBet;
      print(players[currentPlayerIndex].name);
      print("currentRoundBet: ${players[currentPlayerIndex].currentRoundBet}");
      print("stack: ${players[currentPlayerIndex].stack}");
      print("potValue: $potValue");
      nextPlayer();
    } else {
    }
  }

  // Player action: Check
  Future<void> check() async{
    if (prevBet == 0) {
      players[currentPlayerIndex].actedThisRound = true;
      nextPlayer();
      print(players[currentPlayerIndex].name);
      print("currentRoundBet: ${players[currentPlayerIndex].currentRoundBet}");
      print("stack: ${players[currentPlayerIndex].stack}");
      print("potValue: $potValue");
    } else {
      print("Cannot Check");
    }
  }

  // Player action: Fold
  Future<void> fold() async{
    players[currentPlayerIndex].actedThisRound = true;
    players[currentPlayerIndex].hasFolded = true;
    nextPlayer();
  }

  //Random number generator
  int random(int min, int max) {
    return min + Random().nextInt(max - min);
  }

  //Computer action
  Future<void> computerActions() async{
    print("comp actions");
    //var actions = [call(), raiseS()];
    //var rand = random(0,2);
    //print(rand);
    //actions[rand];
    if (players[currentPlayerIndex].hasFolded = true {
      nextPlayer();
    }
    var actions = [call, raiseS];
    var rand = Random().nextInt(2);
    print(rand);
    actions[rand]();
    /*
    while(true) {
      if (bettingRoundComplete()) {
        return;
      }
      var actions = [fold(), check(), call(), raiseS(), raiseP(), raiseA()];
      Random random = new Random();
      int randomNumber = random.nextInt(6);
        Future.delayed(const Duration(seconds: 2), () {
          actions[randomNumber];
        });
        nextPlayer();
    } */
  }
}