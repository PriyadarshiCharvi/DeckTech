import 'package:decktech/gameplay/poker_game.dart';
import 'package:decktech/models/player_model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late PokerGame pokerGame;
  bool isLoading = true;

  late List<AnimationController> _communityCardControllers;
  late List<Animation<Offset>> _communityCardAnimations;

  late List<AnimationController> _playerCardControllers;
  late List<Animation<Offset>> _playerCardAnimations;

  AnimationController? _player1CardController;
  Animation<Offset>? _player1CardAnimation;

  AnimationController? _player2CardController;
  Animation<Offset>? _player2CardAnimation;

  AnimationController? _player3CardController;
  Animation<Offset>? _player3CardAnimation;

  @override
  void initState() {
    super.initState();
    pokerGame = PokerGame();
    pokerGame.players = [
      PlayerModel(name: 'You', isHuman: true),
      PlayerModel(name: 'Computer 1'),
      PlayerModel(name: 'Computer 2'),
      PlayerModel(name: 'Computer 3'),
    ];

    // Initialize animation controllers and animations for community cards
    _communityCardControllers = List.generate(5, (_) => AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    ));

    _communityCardAnimations = _communityCardControllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, -3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));
    }).toList();

    // Initialize animation controllers and animations for player cards
    _playerCardControllers = List.generate(2, (_) => AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    ));

    _playerCardAnimations = _playerCardControllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));
    }).toList();

    // Initialize animation controllers and animations for opponent cards
    _player1CardController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _player1CardAnimation = Tween<Offset>(
      begin: const Offset(-3, 0), // Off-screen to the left
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _player1CardController!,
      curve: Curves.easeOut,
    ));

    _player2CardController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _player2CardAnimation = Tween<Offset>(
      begin: const Offset(0, -3), // Off-screen above
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _player2CardController!,
      curve: Curves.easeOut,
    ));

    _player3CardController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _player3CardAnimation = Tween<Offset>(
      begin: const Offset(3, 0), // Off-screen to the right
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _player3CardController!,
      curve: Curves.easeOut,
    ));

    pokerGame.startGame().then((_) {
      setState(() {
        isLoading = false;
        _startAnimations();
      });
    });
  }

  void _startAnimations() {
    // Start animations for community cards
    for (int i = 0; i < _communityCardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        _communityCardControllers[i].forward();
      });
    }

    // Start animations for player cards
    for (int i = 0; i < _playerCardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        _playerCardControllers[i].forward();
      });
    }

    // Start animations for opponent cards based on game logic
    // For example, when dealing opponent cards
    _player1CardController!.forward();
    _player2CardController!.forward();
    _player3CardController!.forward();
  }

  @override
  void dispose() {
    for (var controller in _communityCardControllers) {
      controller.dispose();
    }
    for (var controller in _playerCardControllers) {
      controller.dispose();
    }
    _player1CardController?.dispose();
    _player2CardController?.dispose();
    _player3CardController?.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 130, 37, 37),
    appBar: AppBar(
      backgroundColor: const Color.fromARGB(255, 158, 110, 110),
      title: const Text('POKER TABLE'),
      leading: BackButton(
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Stack(
          
            children: [
              // Background poker table image
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/backdrop.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Player 2', // Replace with actual player name or identifier
                              style: TextStyle(color: Colors.white),
                            ),
                            SlideTransition(
                              position: _player2CardAnimation!,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Image.asset(
                                      'assets/card_back.png', // Replace with your card back image asset path
                                      width: 40,
                                      height: 60,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Image.asset(
                                      'assets/card_back.png', // Replace with your card back image asset path
                                      width: 40,
                                      height: 60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                  const SizedBox(height: 1),
                  // Opponents' cards and Community cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Player 1 (left of community cards)
                      if (_player1CardAnimation != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Player 1', 
                              style: TextStyle(color: Colors.white),
                            ),
                            SlideTransition(
                              position: _player1CardAnimation!,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Image.asset(
                                      'assets/card_back.png', 
                                      width: 40,
                                      height: 60,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Image.asset(
                                      'assets/card_back.png', 
                                      width: 40,
                                      height: 60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      // Player 2 (above community cards)
                      Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: pokerGame.communityCards.asMap().entries.map((entry) {
                      int idx = entry.key;
                      var card = entry.value;
                      return SlideTransition(
                        position: _communityCardAnimations[idx],
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: CachedNetworkImage(
                            imageUrl: card.image,
                            width: 40,
                            height: 60,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                      );
                    }).toList(),
                  ),   
                      // Player 3 (right of community cards)
                      if (_player3CardAnimation != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Player 3', 
                              style: TextStyle(color: Colors.white),
                            ),
                            SlideTransition(
                              position: _player3CardAnimation!,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Image.asset(
                                      'assets/card_back.png', 
                                      width: 40,
                                      height: 60,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Image.asset(
                                      'assets/card_back.png', 
                                      width: 40,
                                      height: 60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'Your Cards',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: pokerGame.players.firstWhere((player) => player.isHuman).cards.asMap().entries.map((entry) {
                          int idx = entry.key;
                          var card = entry.value;
                          return SlideTransition(
                            position: _playerCardAnimations[idx],
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: CachedNetworkImage(
                                imageUrl: card.image,
                                width: 40,
                                height: 60,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
  );
}

}
