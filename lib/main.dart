// import 'package:decktech/screens/auth_page.dart';
// ignore: unused_import
import 'package:decktech/models/orientation_model.dart';
import 'package:decktech/screens/exit_screen.dart';
import 'package:decktech/screens/game_screen.dart';
import 'package:decktech/screens/home_screen.dart';
import 'package:decktech/screens/login_screen.dart';
import 'package:decktech/screens/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(DeckTech());
}

class DeckTech extends StatelessWidget {
  // const DeckTech({super.key});

  final _observer = NavigatorObserverWithOrientation();

  DeckTech({super.key});

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    if (settings.name == AppRoutes.home) {
      return MaterialPageRoute(builder: (context) => const ExitScreen());
    } else if (settings.name == AppRoutes.portrait) {
      return MaterialPageRoute(
        builder: (context) => LoginScreen(),
        settings: rotationSettings(settings, ScreenOrientation.portraitOnly),
      );
    } else if (settings.name == AppRoutes.landscape) {
      return MaterialPageRoute(
        builder: (context) => const HomeScreen(),
        settings: rotationSettings(settings, ScreenOrientation.landscapeOnly),
      );
    } else if (settings.name == AppRoutes.rotating) {
      return MaterialPageRoute(
        builder: (context) => const GameScreen(),
        settings: rotationSettings(settings, ScreenOrientation.landscapeOnly),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      onGenerateRoute: _onGenerateRoute,
      navigatorObservers: [_observer],
    );
  }

}
