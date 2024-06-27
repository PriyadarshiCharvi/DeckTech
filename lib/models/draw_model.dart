import 'package:decktech/models/card_model.dart';

class DrawModel {
  final int remaining;
  final List<CardModel> cards;

  DrawModel({
    required this.remaining,
    this.cards = const [],
  });

  factory DrawModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> cardList = json['cards'];
    final List<CardModel> cards = cardList.map((card) => CardModel.fromJson(card)).toList();

    return DrawModel(
      remaining: json['remaining'],
      cards: cards,
    );
  }
}
