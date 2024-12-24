import 'package:decktech/screens/game_screen.dart';
import 'package:decktech/screens/home_screen.dart';
import 'package:decktech/screens/spectate_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const home = "/";
  static const landscape = "/landscape";
  static const rotating = "/rotating";
  static const landscape2 = "/spectate";

  static Map<String, WidgetBuilder> routes = {
    landscape: (context) => const HomeScreen(),
    rotating: (context) => const GameScreen(),
    landscape2: (context) => const SpectateScreen(), 
  };
}
