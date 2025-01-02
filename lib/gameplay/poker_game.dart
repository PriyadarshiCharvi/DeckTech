// poker_game.dart

// ignore_for_file: avoid_print

import 'dart:async';

import 'package:decktech/models/card_model.dart';
import 'package:decktech/models/deck_model.dart';
import 'package:decktech/models/draw_model.dart';
import 'package:decktech/models/player_model.dart';
import 'package:decktech/screens/deck_service.dart';
import 'dart:math';

import 'package:poker/poker.dart';

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
    deck = await deckService.newDeck();

    for (PlayerModel player in players) {
      DrawModel draw = await deckService.drawCards(deck, count: 2);
      player.cards = draw.cards;
    }

    DrawModel draw = await deckService.drawCards(deck, count: 5);
    communityCards = draw.cards;
  }

  // Check if betting round is complete
  bool isBettingComplete() {
    for (PlayerModel player in players) {
      if (!player.hasFolded && !player.isAllIn && player.stack != 0) {
        if (player.actedThisRound) {
          if (player.hasBet != roundBet) {return false;}
        } else {return false;}
      }
    }
    return true;
  }

  shiftPositions () {
    int playerIndex = 0;
    while (playerIndex < 6) {
      if (players[playerIndex].position == 0) {
        if (players[playerIndex].hasFolded) {
          players[playerIndex].position = 100;
        } else {
          players[playerIndex].position = 5;
        }
        break;
      }
      else {playerIndex++;}
    }
    playerIndex++;
    int position = 0;
    while (true) {
      playerIndex = playerIndex % 6;
      if (players[playerIndex].position == 0) {break;}
      else if (!players[playerIndex].hasFolded) {
        players[playerIndex].position = position;
        playerIndex++;
        position++;
      }
      else {
        players[playerIndex].position = 100;
        playerIndex++;
      }
    }
  }

  // Player action: Raise by 5
  Future<void> raise5() async{
    PlayerModel player = players[currentPlayerIndex];
    if (roundBet > 5) {
      print("Raising by 5 is not a valid raise");
      callLogic();
    } else {
      int bet = 5 + roundBet;

      if (player.actedThisRound) { //RETRACTING PREVIOUS BET
        player.stack += player.hasBet;
        player.hasBet = 0;
      }

      if ((bet >= player.stack)) { //STACK TOO SMALL
        print("${player.name}'s stack not big enough to raise by 5");
        raiseAllIn();
      } else {
        player.stack -= bet;
        player.hasBet = bet;
        roundBet = bet;
        //PRINTS AND INDICATIONS
        print("${player.name} raises by 5");
        print("${player.name} current round bet: ${player.hasBet}");
        print("${player.name} stack: ${player.stack}");
        print("Pot: $pot");
        player.actedThisRound = true;
      }
    }
  }

  // Player action: Raise by 20
  Future<void> raise3x() async{
    PlayerModel player = players[currentPlayerIndex];
    int bet = 3 * roundBet;
    if (player.actedThisRound) { //RETRACTING PREVIOUS BET
      player.stack += player.hasBet;
    }
    if ((bet >= player.stack)) { //STACK TOO SMALL
      print("${player.name}'s stack not big enough to raise 3x");
      raiseAllIn();
    } else {
      player.stack -= bet;
      player.hasBet = bet;
      roundBet = bet;
      //PRINTS AND INDICATIONS
      print("${player.name} raises 3x");
      print("${player.name} current round bet: ${player.hasBet}");
      print("${player.name} stack: ${player.stack}");
      print("Pot: $pot");
      player.actedThisRound = true;
    }
  }

  // Player action: All in
  Future<void> raiseAllIn() async{
    PlayerModel player = players[currentPlayerIndex];
    int bet = player.stack;
    player.stack = 0;
    player.isAllIn = true;
    player.hasBet = bet;

    if (bet > roundBet) {roundBet = bet;} // IF RAISE ALL IN

    //PRINTS AND INDICATIONS
    print("${player.name} is all in");
    print("${player.name} current round bet: ${player.hasBet}");
    print("${player.name} stack: ${player.stack}");
    print("Pot: $pot");
    player.actedThisRound = true;
  }

  Future<void> call() async{
    int bet = roundBet;
    PlayerModel player = players[currentPlayerIndex];
    player.stack -= bet;
    player.hasBet = bet;
    //PRINTS AND INDICATIONS
    print("${player.name} calls");
    print("${player.name} current round bet: ${player.hasBet}");
    print("${player.name} stack: ${player.stack}");
    print("Pot: $pot");
    player.actedThisRound = true;
  }

  // Player action: Call
  Future<void> callLogic() async{
    int bet = roundBet;
    PlayerModel player = players[currentPlayerIndex];
    if (bet == 0) {check();}
    else {
      if (player.actedThisRound) { //RETRACTING PREVIOUS BET
        player.stack += player.hasBet;
      }
      if ((bet >= player.stack)) {raiseAllIn();} //STACK TOO SMALL
      else {call();}
    }
  }

  // Player action: Check
  Future<void> check() async{
    PlayerModel player = players[currentPlayerIndex];
    if (roundBet == 0) {
      //PRINTS AND INDICATIONS
      print("${player.name} checks");
      print("${player.name} current round bet: ${player.hasBet}");
      print("${player.name} stack: ${player.stack}");
      print("Pot: $pot");
      player.actedThisRound = true;
    } else {
      print("Cannot Check");
      if (currentPlayerIndex != 0) {computerActions();}
    }
  }

  // Player action: Fold
  Future<void> fold() async{
    PlayerModel player = players[currentPlayerIndex];
    player.hasFolded = true;
    //PRINTS AND INDICATIONS
    print("${player.name} folds");
    print("${player.name} current round bet: ${player.hasBet}");
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

    PlayerModel player = players[currentPlayerIndex];
    List<CardModel> hand = player.cards;

    Card playerCard1 = Card.parse(hand[0].getCode());
    Card playerCard2 = Card.parse(hand[1].getCode());

    String communityCardsString = communityCards.map((card) => card.getCode()).join();

    int communityCardCount = communityCards.length;
    String gameState = '';

    if (communityCardCount == 0) {
      gameState = 'pre-flop';
    } else if (communityCardCount == 3) {
      gameState = 'flop';
    } else if (communityCardCount == 4) {
      gameState = 'turn';
    } else if (communityCardCount == 5) {
      gameState = 'river';
    }

    MadeHand playerHandStrength;

    if (gameState == 'pre-flop') {
      if (playerCard1.rank == playerCard2.rank && playerCard1.rank.index > 5) {
        raise5();
      } else if (playerCard1.rank.index >= 10 || playerCard2.rank.index >= 10) {
        callLogic();
      } else {
        fold();
      }
    } else {
      playerHandStrength = MadeHand.best(ImmutableCardSet.parse("$playerCard1$playerCard2$communityCardsString"));

      if (gameState == 'flop' || gameState == 'turn') {
        if (playerHandStrength.type.index >= MadeHandType.twoPairs.index) {
          raise3x();
        } else if (playerHandStrength.type == MadeHandType.pair) {
          if (roundBet == 0) {check();}
          else {callLogic();}
        } else {
          if (roundBet == 0) {check();}
          else {fold();}
        }
      } else if (gameState == 'river') {
        if (playerHandStrength.type.index >= MadeHandType.straight.index) {
          raiseAllIn();
        } else if (playerHandStrength.type == MadeHandType.trips) {
          raise3x();
        } else if (playerHandStrength.type == MadeHandType.twoPairs) {
          if (roundBet == 0) {check();}
          else {callLogic();}
        } else {
          if (roundBet == 0) {check();}
          else {fold();}
        }
      }
    }
  }

  //Return index of winning player/s at showdown
  List getWinningPlayers(playersInHand) {
    List<CardPair> playerCardPairs = [];
    for (PlayerModel player in playersInHand) {
      playerCardPairs.add(CardPair.parse("${player.cards[0].getCode()}${player.cards[1].getCode()}"));
    }
    String communityCardsString = ("${communityCards[0].getCode()}${communityCards[1].getCode()}"
        "${communityCards[2].getCode()}${communityCards[3].getCode()}${communityCards[4].getCode()}");
    ImmutableCardSet communityCardsList =  ImmutableCardSet.parse(communityCardsString);
    Matchup match = Matchup.showdown(playerCardPairs: playerCardPairs, communityCards: communityCardsList);
    return match.wonPlayerIndexes.toList();
  }

  //Splits pot between multiple winners
  splitPot(List listOfWinners, playersInHand) {
    int numberOfWinners = listOfWinners.length;
    int individualWinnings = (pot/numberOfWinners).floor();
    for (int playerIndex in listOfWinners) {
      playersInHand[playerIndex].stack += individualWinnings;
    }
  }
}