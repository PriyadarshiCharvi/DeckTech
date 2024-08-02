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
  int nextPlayer() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;

    if (currentPlayerIndex != 0) {
      computerActions();
      return 0;
    } else {
      if (players[0].hasFolded == true) {
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
  bool bettingRoundComplete() {
    var standard = 0;
    int counter = 0;
    int tempWinningPlayer = 0;

    for (var playerIndex = 0; playerIndex < 4; playerIndex++) {
      if (players[playerIndex].hasFolded) {counter += 1;}
      else {
        tempWinningPlayer = playerIndex;
        if (!players[playerIndex].isAllIn) standard = players[playerIndex].currentRoundBet;
      }
    }

    //All other players fold
    if (counter == 3) {
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

    for (var playerIndex = 0; playerIndex < 4; playerIndex++) {
      if (!players[playerIndex].actedThisRound || ((!players[playerIndex].hasFolded) && players[playerIndex].currentRoundBet != standard && !players[playerIndex].isAllIn)) {
        return false;
      }
    }
    return true;
  }

  // Round end
  Future<void> roundEnd() async{
      for (int playerIndex = 0; playerIndex < 4; playerIndex++) {
        players[playerIndex].currentRoundBet = 0;
        players[playerIndex].actedThisRound = false;
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

      if (bettingRoundComplete()) {roundEnd();}
      else {nextPlayer();}
    } else {
      print("Cannot Raise 50");
      if (currentPlayerIndex != 0) computerActions();
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

      if (bettingRoundComplete()) {roundEnd();}
      else {nextPlayer();}
    } else {
      print("Cannot Raise 150");
      if (currentPlayerIndex != 0) computerActions();
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
    if (betAmount > prevBet) prevBet = betAmount;

    print("${players[currentPlayerIndex].name} all in");
    print("${players[currentPlayerIndex].name} current round bet: ${players[currentPlayerIndex].currentRoundBet}");
    print("${players[currentPlayerIndex].name} stack: ${players[currentPlayerIndex].stack}");
    print("Pot: $potValue");

    if (bettingRoundComplete()) {roundEnd();}
    else {nextPlayer();}
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

      if (bettingRoundComplete()) {roundEnd();}
      else {nextPlayer();}
    } else {
      print("Cannot Call");
      if (currentPlayerIndex != 0) computerActions();
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

      if (bettingRoundComplete()) {roundEnd();}
      else {nextPlayer();}
    } else {
      print("Cannot Check");
      if (currentPlayerIndex != 0) computerActions();
    }
  }

  // Player action: Fold
  Future<void> fold() async{
    players[currentPlayerIndex].actedThisRound = true;
    players[currentPlayerIndex].hasFolded = true;

    print("${players[currentPlayerIndex].name} fold");
    print("${players[currentPlayerIndex].name} current round bet: ${players[currentPlayerIndex].currentRoundBet}");
    print("${players[currentPlayerIndex].name} stack: ${players[currentPlayerIndex].stack}");
    print("Pot: $potValue");

    players[currentPlayerIndex].currentRoundBet = prevBet;

    if (bettingRoundComplete()) {roundEnd();}
    else {nextPlayer();}
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

    if (rand < 50) {call();}
    else if (rand < 72) {raiseS();}
    else if (rand < 85) {raiseP();}
    else if (rand < 90) {raiseA();}
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

/*

Card player1card1 = Card(rank: Rank.ace, suit: Suit.spades);

Hand player1hand = Hand(cards: [player1card1, player2card2]);

List<Card> communityCards = [card1, card2, card3, card4, card5];

HandResult result = HandEvaluator.evaluate(player1hand, communityCards);

print(‘Best Hand: ${result.bestHand}’);

print(‘Hand Rank: ${result.rank}’);

"cards": [
        {
            "image": "https://www.deckofcardsapi.com/static/img/AS.png",
            "value": "ACE",
            "suit": "SPADES",
            "code": "AS"
        }
    ]
 */