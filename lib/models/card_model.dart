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