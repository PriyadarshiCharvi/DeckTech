import 'package:decktech/models/orientation_model.dart';
import 'package:decktech/screens/game_screen.dart';
import 'package:decktech/screens/home_screen.dart';
import 'package:decktech/screens/spectate_screen.dart'; 
import 'package:decktech/screens/routes.dart';
import 'package:flutter/material.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(DeckTech());
}

class DeckTech extends StatelessWidget {
  final _observer = NavigatorObserverWithOrientation();

  DeckTech({super.key});

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    if (settings.name == AppRoutes.landscape) {
      return MaterialPageRoute(
        builder: (context) => const HomeScreen(),
        settings: rotationSettings(settings, ScreenOrientation.landscapeOnly),
      );
    } else if (settings.name == AppRoutes.rotating) {
      return MaterialPageRoute(
        builder: (context) => const GameScreen(),
        settings: rotationSettings(settings, ScreenOrientation.landscapeOnly),
      );
    } else if (settings.name == AppRoutes.landscape2) { 
      return MaterialPageRoute(
        builder: (context) => const SpectateScreen(),
        settings: rotationSettings(settings, ScreenOrientation.landscapeOnly),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      onGenerateRoute: _onGenerateRoute,
      navigatorObservers: [_observer],
    );
  }
}
