
import 'package:decktech/models/deck_model.dart';
import 'package:decktech/models/draw_model.dart';
import 'package:decktech/screens/api_service.dart';


class DeckService extends ApiService {

  Future<DeckModel> newDeck([int deckCount = 1]) async {

    final data = await httpGet(
      '/deck/new/shuffle', 
      params: {'deck_count': deckCount},
    );

    return DeckModel.fromJson(data);

  }

  Future<DrawModel> drawCards(DeckModel deck, {int count = 1}) async {

    final data = await httpGet(
      '/deck/${deck.deck_id}/draw', 
      params: {'count': count},
      );

      return DrawModel.fromJson(data);
  
  }
}