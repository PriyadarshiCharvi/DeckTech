// poker_game.dart

// ignore_for_file: avoid_print

import 'dart:async';

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
  int pot = 0;
  int roundBet = 0;

  PokerGame() {
    deckService = DeckService();
    players = [];
  }

  Future<void> startGame() async {
    try {
      deck = await deckService.newDeck();

      for (PlayerModel player in players) {
        DrawModel draw = await deckService.drawCards(deck, count: 2);
        player.cards = draw.cards;
        print("${player.name} hand: ${player.cards[0].toString()}, ${player.cards[1].toString()}");
      }

      DrawModel draw = await deckService.drawCards(deck, count: 5);
      communityCards = draw.cards;

      if (kDebugMode) {
        print("Community cards: ${communityCards[0].toString()}, ${communityCards[1].toString()}, "
            "${communityCards[2].toString()}, ${communityCards[3].toString()}, ${communityCards[4].toString()}");
      }

    } catch (e) {
      if (kDebugMode) {
        print("Error in startGame: $e");
      }
    }
  }

  //Next player action handler
  void nextPlayer() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    if (currentPlayerIndex != 0) {
      computerActions();
    } else {
      print("------ACTION ON YOU------");
      if (players[0].hasFolded) {
        print("You have folded");
      } else if (players[0].isAllIn) {
        print("You are all in");
      }
    }
  }

  // Check if betting round is complete
  bool isBettingRoundComplete() {
    int validAction = 0;
    for (var playerIndex = 0; playerIndex < 6; playerIndex++) {
      PlayerModel player = players[playerIndex];
      if (!player.actedThisRound) return false;
      if (player.hasFolded) {validAction += 1;}
      else if (player.isAllIn) {validAction += 1;}
      else if (player.currentRoundBet == roundBet) {validAction += 1;}
    }
    return (validAction == 6);
  }

  // Round end
  Future<void> roundEnd() async{
    int playerCounter = 0;
    for (int playerIndex = 0; playerIndex < 6; playerIndex++) {
      PlayerModel player = players[playerIndex];
      player.currentRoundBet = 0;
      player.actedThisRound = false;
      if (!player.hasFolded) playerCounter += 1;
    }
    roundBet = 0;
    print("-------------BETTING ROUND COMPLETE-------------");
    print("------PRESS NEXT TO ADVANCE TO NEXT STREET------");
    print("-------------------$playerCounter PLAYERS--------------------");
    return;
  }

  // Player action: Raise by 5
  Future<void> raise5() async{
    int bet = 5 + roundBet;
    PlayerModel player = players[currentPlayerIndex];
    if (player.actedThisRound) { //RETRACTING PREVIOUS BET
      pot -= player.currentRoundBet;
      player.stack += player.currentRoundBet;
      player.currentRoundBet = 0;
    }
    if ((bet >= player.stack)) { //STACK TOO SMALL
      print("${player.name}'s stack not big enough to raise by 5");
      raiseAllIn();
    } else {
      pot += bet;
      player.stack -= bet;
      player.currentRoundBet += bet;
      roundBet = bet;
      //PRINTS AND INDICATIONS
      print("${player.name} raises by 5");
      print("${player.name} current round bet: ${player.currentRoundBet}");
      print("${player.name} stack: ${player.stack}");
      print("Pot: $pot");
      player.actedThisRound = true;
    }
  }

  // Player action: Raise by 20
  Future<void> raise20() async{
    int bet = 20 + roundBet;
    PlayerModel player = players[currentPlayerIndex];
    if (player.actedThisRound) { //RETRACTING PREVIOUS BET
      pot -= player.currentRoundBet;
      player.stack += player.currentRoundBet;
      player.currentRoundBet = 0;
    }
    if ((bet >= player.stack)) { //STACK TOO SMALL
      print("${player.name}'s stack not big enough to raise by 20");
      raiseAllIn();
    } else {
      pot += bet;
      player.stack -= bet;
      player.currentRoundBet += bet;
      roundBet = bet;
      //PRINTS AND INDICATIONS
      print("${player.name} raises by 20");
      print("${player.name} current round bet: ${player.currentRoundBet}");
      print("${player.name} stack: ${player.stack}");
      print("Pot: $pot");
      player.actedThisRound = true;
    }
  }

  // Player action: All in
  Future<void> raiseAllIn() async{
    PlayerModel player = players[currentPlayerIndex];
    int bet = player.stack + player.currentRoundBet;
    player.stack = 0;
    player.isAllIn = true;
    pot += bet - player.currentRoundBet;
    player.currentRoundBet = bet;

    if (bet > roundBet) {
      roundBet = bet;
    }
    //PRINTS AND INDICATIONS
    print("${player.name} is all in");
    print("${player.name} current round bet: ${player.currentRoundBet}");
    print("${player.name} stack: ${player.stack}");
    print("Pot: $pot");
    player.actedThisRound = true;
  }

  // Player action: Call
  Future<void> call() async{
    int bet = roundBet;
    PlayerModel player = players[currentPlayerIndex];
    if (bet == 0) {
      check();
    } else {
      if (player.actedThisRound) { //RETRACTING PREVIOUS BET
        pot -= player.currentRoundBet;
        player.stack += player.currentRoundBet;
        player.currentRoundBet = 0;
      }
      if ((bet >= player.stack)) { //STACK TOO SMALL
        raiseAllIn();
      } else {
        pot += bet;
        player.stack -= bet;
        player.currentRoundBet += bet;
        roundBet = bet;
        //PRINTS AND INDICATIONS
        print("${player.name} calls");
        print("${player.name} current round bet: ${player.currentRoundBet}");
        print("${player.name} stack: ${player.stack}");
        print("Pot: $pot");
        player.actedThisRound = true;
      }
    }
  }

  // Player action: Check
  Future<void> check() async{
    PlayerModel player = players[currentPlayerIndex];
    if (roundBet == 0) {
      //PRINTS AND INDICATIONS
      print("${player.name} checks");
      print("${player.name} current round bet: ${player.currentRoundBet}");
      print("${player.name} stack: ${player.stack}");
      print("Pot: $pot");
      player.actedThisRound = true;
    } else {
      print("Cannot Check");
      if (currentPlayerIndex != 0) computerActions();
    }
  }

  // Player action: Fold
  Future<void> fold() async{
    PlayerModel player = players[currentPlayerIndex];
    player.hasFolded = true;
    //PRINTS AND INDICATIONS
    print("${player.name} folds");
    print("${player.name} current round bet: ${player.currentRoundBet}");
    print("${player.name} stack: ${player.stack}");
    print("Pot: $pot");
    player.actedThisRound = true;
  }

  //Initialize random number generator
  int random(int min, int max) {
    return min + Random().nextInt(max - min);
  }

  //Computer action
  Future<void> computerActions() async{
    print("------${players[currentPlayerIndex].name} ACTION------");

    if (players[currentPlayerIndex].hasFolded) {
      print("${players[currentPlayerIndex].name} has folded");
    } else if (players[currentPlayerIndex].isAllIn) {
      print("${players[currentPlayerIndex].name} is all in");
    } else {
      var rand = random(0, 100);
      if (rand < 40) {
        call();
      }
      else if (rand < 60) {
        raise5();
      }
      else if (rand < 78) {
        raise20();
      }
      else if (rand < 85) {
        raiseAllIn();
      }
      else {
        fold();
      }
    }
  }

  //Declare winner
  Future<void> winner(int playerIndex) async{
    //TODO - other win conditions
    print("${players[playerIndex].name} IS THE ONLY REMAINING PLAYER");
    print("${players[playerIndex].name} WINS THE GAME");
    roundEnd();
  }

}