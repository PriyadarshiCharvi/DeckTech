import 'dart:convert';

import 'package:validators/sanitizers.dart';
import "package:http/http.dart" as http;

class ApiService {

   static const baseUrl = "https://www.deckofcardsapi.com/api";

    Future<Map<String, dynamic>> fetchCards(String deckId, {int count = 1}) async {
    final response = await http.get(Uri.parse('$baseUrl/deck/$deckId/draw/?count=$count'));
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load cards');
    }
  }

   Uri _url(String path, [Map<String, dynamic> params = const {}]) {
    String queryString = "";
    if (params.isNotEmpty) {
      queryString = "?";
      params.forEach(
        (k, v) {
          queryString += "$k=${v.toString()}&";
        },
      );
    }

    path = rtrim(path, '/');
    path = ltrim(path, '/');
    queryString = rtrim(queryString, '&');

    final url = '$baseUrl/$path/$queryString';
    return Uri.parse(url);
   }

   Future<Map<String, dynamic>> httpGet(String path, {Map<String, dynamic> params = const{},
   }) async {
    final url = _url(path, params);
    
    final response = await http.get(url);
    if (response.bodyBytes.isEmpty) {
      return {};
    }

    return jsonDecode(utf8.decode(response.bodyBytes));
   }

}