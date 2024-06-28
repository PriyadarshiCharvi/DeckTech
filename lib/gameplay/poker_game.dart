// poker_game.dart

// ignore_for_file: avoid_print

import 'package:decktech/models/card_model.dart';
import 'package:decktech/models/deck_model.dart';
import 'package:decktech/models/draw_model.dart';
import 'package:decktech/models/player_model.dart';
import 'package:decktech/screens/deck_service.dart';
import 'package:flutter/foundation.dart';

class PokerGame {
  List<PlayerModel> players = [];
  late DeckService deckService;
  late DeckModel deck;
  List<CardModel> communityCards = [];
  int currentPlayerIndex = 0;

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
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
  }

  // Add more methods for betting, revealing cards, etc.
}