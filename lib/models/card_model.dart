import 'package:flutter/material.dart';

class CardModel {
  final String image;
  final String suit;
  final String value;

  CardModel({
    required this.image,
    required this.suit,
    required this.value,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      image: json['image'] ?? '', // Ensure to handle nullability
      suit: json['suit'] ?? '', // Convert suit string to enum
      value: json['value'] ?? '', // Ensure to handle nullability
    );
  }

  @override
  toString() {
    return ("$value of $suit");
  }


  // static Suit stringToSuit(String? suit) {
  //   switch (suit?.toUpperCase().trim()) {
  //     case "HEARTS":
  //       return Suit.Hearts;
  //     case "CLUBS":
  //       return Suit.Clubs;
  //     case "DIAMONDS":
  //       return Suit.Diamonds;
  //     case "SPADES":
  //       return Suit.Spades;
  //     default:
  //       throw "ERROR";
  //   }
  // }

  // static String suitToString(Suit suit) {
  //   switch (suit) {
  //     case Suit.Hearts:
  //       return "Hearts";
  //     case Suit.Clubs:
  //       return "Clubs";
  //     case Suit.Diamonds:
  //       return "Diamonds";
  //     case Suit.Spades:
  //       return "Spades";
  //   }
  // }

  static String suitToUnicode(String suit) {
    switch (suit) {
      case "Hearts":
        return "\u2665";
      case "Clubs":
        return "\u2663";
      case "Diamonds":
        return "\u2666";
      case "Spades":
        return "\u2660";
      default:
        throw "ERROR";
    }
  }

  static Color suitToColor(String suit) {
    switch (suit) {
      case "Hearts":
      case "Diamonds":
        return Colors.red;
      case "Clubs":
      case "Spades":
        return Colors.black;
      default:
        throw "ERROR";
    }
  }

}