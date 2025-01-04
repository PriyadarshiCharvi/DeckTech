// poker_game.dart

// ignore_for_file: avoid_print

import 'dart:async';

import 'package:decktech/models/card_model.dart';
import 'package:decktech/models/deck_model.dart';
import 'package:decktech/models/draw_model.dart';
import 'package:decktech/models/player_model.dart';
import 'package:decktech/screens/deck_service.dart';
import 'package:flutter/cupertino.dart';
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
  int revealState = 0;

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
      if (player.hasFolded) {
        continue;
      } else if (player.isAllIn) {
        continue;
      } else if (player.stack == 0) {
        continue;
      } else if(!player.actedThisRound) {
        return false;
      } else if (player.actedThisRound && player.hasBet == roundBet) {
        continue;
      } else {
        return false;
      }
    }
    return true;
  }

  bool currentPlayerCannotAct() {
    return (players[currentPlayerIndex].hasFolded ||
        players[currentPlayerIndex].isAllIn ||
        players[currentPlayerIndex].stack == 0);
  }

  void shiftPlayerIndex() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
  }

  void shiftPositions () {
    int playerIndex = 0;
    while (playerIndex < 6) {
      if (players[playerIndex].position == 0) {
        if (players[playerIndex].hasFolded) {
          players[playerIndex].position = 100;
        } else {
          players[playerIndex].position = 5;
        }
        break;
      } else {
        playerIndex++;
      }
    }
    playerIndex++;
    int position = 0;
    while (true) {
      playerIndex = playerIndex % 6;
      if (players[playerIndex].position == 0) {
        break;
      } else if (!players[playerIndex].hasFolded) {
        players[playerIndex].position = position;
        playerIndex++;
        position++;
      } else {
        players[playerIndex].position = 100;
        playerIndex++;
      }
    }
  }

  // Player action: Raise small
  Future<void> raiseSmall() async{
    PlayerModel player = players[currentPlayerIndex];

    int bet;
    if (roundBet == 0) {
      bet = (pot*0.33).floor();
    } else {
      bet = (roundBet*2.5).floor();
    }

    player.retractPreviousBet();
    if ((bet >= player.stack)) { //STACK TOO SMALL
      print("${player.name}'s stack not enough to bet small");
      raiseAllIn();
    } else {
      player.bet(bet);
      roundBet = bet;
      player.actedThisRound = true;

      //PRINTS AND INDICATIONS
      print("${player.name} raises small");
      print("${player.name} current round bet: ${player.hasBet}");
      print("${player.name} stack: ${player.stack}");
      print("Pot: $pot");
    }
  }

  // Player action: Raise big
  Future<void> raiseBig() async{
    PlayerModel player = players[currentPlayerIndex];

    int bet;
    if (roundBet == 0) {
      bet = (pot*0.66).floor();
    } else {
      bet = (roundBet*4.5).floor();
    }

    player.retractPreviousBet();
    if ((bet >= player.stack)) { //STACK TOO SMALL
      print("${player.name}'s stack not enough to raise big");
      raiseAllIn();
    } else {
      player.bet(bet);
      roundBet = bet;
      player.actedThisRound = true;

      //PRINTS AND INDICATIONS
      print("${player.name} raises big");
      print("${player.name} current round bet: ${player.hasBet}");
      print("${player.name} stack: ${player.stack}");
      print("Pot: $pot");
    }
  }

  // Player action: All in
  Future<void> raiseAllIn() async{
    PlayerModel player = players[currentPlayerIndex];
    int bet = player.stack;
    player.bet(bet);
    player.isAllIn = true;

    if (bet > roundBet) {
      roundBet = bet;
    } // IF RAISE (NOT CALL)

    //PRINTS AND INDICATIONS
    print("${player.name} is all in");
    print("${player.name} current round bet: ${player.hasBet}");
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
      player.retractPreviousBet();
      if ((bet >= player.stack)) { //STACK TOO SMALL
        raiseAllIn();
      } else {
        player.bet(bet);
        //PRINTS AND INDICATIONS
        print("${player.name} calls");
        print("${player.name} current round bet: ${player.hasBet}");
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
      print("${player.name} current round bet: ${player.hasBet}");
      print("${player.name} stack: ${player.stack}");
      print("Pot: $pot");
      player.actedThisRound = true;
    } else {
      print("Cannot Check");
      if (currentPlayerIndex != 0) {
        computerActions();
      }
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

  // Check if possible, fold otherwise
  void checkFold() {
    if (roundBet == 0) {
      check();
    } else {
      fold();
    }
  }

  // Check if possible, call otherwise
  void checkCall() {
    if (roundBet == 0) {
      check();
    } else {
      call();
    }
  }

  //Initialize random number generator
  bool random(int odds) {
    return (Random().nextInt(100) <= odds);
  }

  List<CardModel> getVisibleCommunityCards() {
    if (revealState >= 5) {
      return communityCards;
    } else {
      return communityCards.sublist(0, revealState);
    }
  }

  //Computer action
  Future<void> computerActions() async {
    print("------${players[currentPlayerIndex].name} ACTION------");

    PlayerModel player = players[currentPlayerIndex];
    List<CardModel> hand = player.cards;

    Card playerCard1 = Card.parse(hand[0].getCode());
    Card playerCard2 = Card.parse(hand[1].getCode());

    List<CardModel> visibleCards = getVisibleCommunityCards();
    String visibleCommunityCards = visibleCards.map((card) => card.getCode())
        .join();
    int communityCardCount = visibleCards.length;
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

    if (gameState == 'pre-flop') {
      if ((playerCard1.rank == playerCard2.rank) || (playerCard1.rank.index >= 10 && playerCard2.rank.index >= 10)) {
        if (random(50)) {
          raiseSmall();
        } else {
          call();
        }
      } else {
        fold();
      }
    }

    else {
      String handToEvaluate = "$playerCard1$playerCard2$visibleCommunityCards";
      MadeHand playerHandStrength = MadeHand.best(
          ImmutableCardSet.parse(handToEvaluate));

      if (gameState == 'flop') {
        if (playerHandStrength.type.index >= MadeHandType.twoPairs.index) {
          raiseBig();
        } else if (playerHandStrength.type == MadeHandType.pair) {
          checkCall();
        } else {
          checkFold();
        }
      }

      else if (gameState == 'turn') {
        if (playerHandStrength.type.index >= MadeHandType.straight.index) {
          raiseAllIn();
        } else if (playerHandStrength.type == MadeHandType.trips) {
          raiseBig();
        } else if (playerHandStrength.type == MadeHandType.twoPairs) {
          raiseSmall();
        } else if (playerHandStrength.type == MadeHandType.pair) {
          checkCall();
        } else {
          checkFold();
        }
      }

      else if (gameState == 'river') {
        if (playerHandStrength.type.index >= MadeHandType.straight.index) {
          raiseAllIn();
        } else if (playerHandStrength.type == MadeHandType.trips) {
          raiseBig();
        } else if (playerHandStrength.type == MadeHandType.twoPairs) {
          raiseSmall();
        } else if (playerHandStrength.type == MadeHandType.pair) {
          checkCall();
        } else {
          checkFold();
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
  void splitPot(List listOfWinners, playersInHand) {
    int numberOfWinners = listOfWinners.length;
    int individualWinnings = (pot/numberOfWinners).floor();
    for (int playerIndex in listOfWinners) {
      playersInHand[playerIndex].stack += individualWinnings;
    }
  }
}