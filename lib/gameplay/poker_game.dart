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
  int prevBet = 0;

  PokerGame() {
    deckService = DeckService();
    players = [];
  }

  Future<void> startGame() async {
    try {
      print("Fetching new deck...");
      deck = await deckService.newDeck();

      for (PlayerModel player in players) {
        print("Drawing cards for ${player.name}:");
        DrawModel draw = await deckService.drawCards(deck, count: 2);
        player.cards = draw.cards;
        print("${player.name} hand: ${player.cards[0].toString()}, ${player.cards[1].toString()}");
      }

      print("Drawing community cards...");
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
  int nextPlayer() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;

    if (currentPlayerIndex != 0) {
      computerActions();
      return 0;
    } else {
      if (players[0].hasFolded) {
        print("You have folded");
        nextPlayer();
      } else if (players[0].isAllIn) {
        print("You are all in");
        nextPlayer();
      }
      print("------ACTION ON YOU------");
      return 1;
    }
  }

  //Check if betting round is complete
  bool isBettingRoundComplete() {
    var standard = 0;
    int counter = 0;
    int tempWinningPlayer = 0;

    for (var playerIndex = 0; playerIndex < 6; playerIndex++) {
      if (players[playerIndex].hasFolded) {
        counter += 1;
      } else {
        tempWinningPlayer = playerIndex;
        if (!players[playerIndex].isAllIn) {
          standard = players[playerIndex].currentRoundBet;
        }
      }
    }

    //All other players fold
    if (counter == 5) {
      winner(tempWinningPlayer);
    }
    /*
    for (var playerIndex = 0; playerIndex < 4; playerIndex++) {
      if (!players[playerIndex].hasFolded && !players[playerIndex].isAllIn) {
        standard = players[playerIndex].currentRoundBet;
        break;
      }
    }
     */

    for (var playerIndex = 0; playerIndex < 6; playerIndex++) {
      if (!players[playerIndex].actedThisRound || ((!players[playerIndex].hasFolded) && players[playerIndex].currentRoundBet != standard && !players[playerIndex].isAllIn)) {
        return false;
      }
    }
    return true;
  }

  // Round end
  Future<void> roundEnd() async{
      for (int playerIndex = 0; playerIndex < 6; playerIndex++) {
        players[playerIndex].currentRoundBet = 0;
        players[playerIndex].actedThisRound = false;
      }
      prevBet = 0;
      print("------BETTING ROUND COMPLETE------");
      print("------PRESS ARROW ON TOP RIGHT------");
      return;
  }

  // Player action: Bet half-pot
  Future<void> raiseH() async{
    int bet = (pot/2).floor();
    PlayerModel player = players[currentPlayerIndex];
    if ((bet <= player.stack) & (prevBet <= bet)) {
      pot += bet;
      player.stack -= bet;
      player.currentRoundBet += bet;
      prevBet = bet;

      print("${player.name} bet half-pot");
      print("${player.name} current round bet: ${player.currentRoundBet}");
      print("${player.name} stack: ${player.stack}");
      print("Pot: $pot");

      player.actedThisRound = true;

    } else {
      print("Cannot bet half-pot");
      if (currentPlayerIndex != 0) computerActions();
    }
  }

  // Player action: Raise by 5
  Future<void> raiseP() async{
    int betAmount = 5 + prevBet;
    PlayerModel player = players[currentPlayerIndex];
    if (betAmount <= player.stack) {
      player.actedThisRound = true;
      pot += betAmount - player.currentRoundBet;
      player.stack -= betAmount - player.currentRoundBet;
      player.currentRoundBet = betAmount;
      prevBet += 5;

      print("${player.name} raise 5");
      print("${player.name} current round bet: ${player.currentRoundBet}");
      print("${player.name} stack: ${player.stack}");
      print("Pot: $pot");

    } else {
      print("Cannot Raise 5");
      if (currentPlayerIndex != 0) computerActions();
    }
  }

  // Player action: All in
  Future<void> raiseA() async{
    PlayerModel player = players[currentPlayerIndex];
    int betAmount = player.stack;
    player.actedThisRound = true;
    player.stack = 0;
    player.isAllIn = true;
    player.currentRoundBet += betAmount;
    pot += betAmount;
    if (betAmount > prevBet) prevBet = betAmount;

    print("${player.name} all in");
    print("${player.name} current round bet: ${player.currentRoundBet}");
    print("${player.name} stack: ${player.stack}");
    print("Pot: $pot");


  }

  // Player action: Call
  Future<void> call() async{
    PlayerModel player = players[currentPlayerIndex];
    if (prevBet <= player.stack) {
      int bet = prevBet - player.currentRoundBet;
      player.actedThisRound = true;
      player.currentRoundBet = prevBet;
      pot += bet;
      player.stack -= bet;

      print("${player.name} calls");
      print("${player.name} current round bet: ${player.currentRoundBet}");
      print("${player.name} stack: ${player.stack}");
      print("Pot: $pot");

    } else {
      print("${player.name} calls all in");
      raiseA();
    }
  }

  // Player action: Check
  Future<void> check() async{
    PlayerModel player = players[currentPlayerIndex];
    if (prevBet == 0) {
      player.actedThisRound = true;

      print("${player.name} check");
      print("${player.name} current round bet: ${player.currentRoundBet}");
      print("${player.name} stack: ${player.stack}");
      print("Pot: $pot");

    } else {
      print("Cannot Check");
      if (currentPlayerIndex != 0) computerActions();
    }
  }

  // Player action: Fold
  Future<void> fold() async{
    PlayerModel player = players[currentPlayerIndex];
    player.actedThisRound = true;
    player.hasFolded = true;

    print("${player.name} fold");
    print("${player.name} current round bet: ${player.currentRoundBet}");
    print("${player.name} stack: ${player.stack}");
    print("Pot: $pot");

    player.currentRoundBet = prevBet;

  }

  //Initialize random number generator
  int random(int min, int max) {
    return min + Random().nextInt(max - min);
  }

  //Computer action
  Future<void> computerActions() async{

    print("------${players[currentPlayerIndex].name} Action------");

    if (players[currentPlayerIndex].hasFolded) {
      print("${players[currentPlayerIndex].name} has folded");
      nextPlayer();
    }

    if (players[currentPlayerIndex].isAllIn) {
      print("${players[currentPlayerIndex].name} is all in");
      nextPlayer();
    }

    var rand = random(0, 100);

    if (rand < 40) {call();}
    else if (rand < 72) {raiseH();}
    else if (rand < 85) {raiseP();}
    else if (rand < 75) {raiseA();}
    else {fold();}

  }

  //Declare winner
  Future<void> winner(int i) async{
    //TODO - other win conditions
    print("${players[i].name} IS THE ONLY REMAINING PLAYER");
    print("${players[i].name} WINS THE GAME");
    roundEnd();
  }

}