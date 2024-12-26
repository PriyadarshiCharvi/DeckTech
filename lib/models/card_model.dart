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
      image: json['image'] ?? '',
      suit: json['suit'] ?? '',
      value: json['value'] ?? '',
    );
  }

  String getCode() {
    if (value[0] == "1") {
      return ("T${suit[0].toLowerCase()}");
    }
    return (value[0] + suit[0].toLowerCase());
  }

  @override
  toString() {
    return ("$value of $suit");
  }
}