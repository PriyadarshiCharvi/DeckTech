// ignore_for_file: avoid_print

import 'package:decktech/gameplay/poker_game.dart';
import 'package:decktech/models/player_model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:poker/poker.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late PokerGame pokerGame;
  bool isLoading = true;

  late List<AnimationController> _communityCardControllers;
  late List<AnimationController> _playerCardControllers;
  AnimationController? _player1CardController;
  AnimationController? _player2CardController;
  AnimationController? _player3CardController;

  late List<Animation<Offset>> _communityCardAnimations;
  late List<Animation<Offset>> _playerCardAnimations;
  Animation<Offset>? _player1CardAnimation;
  Animation<Offset>? _player2CardAnimation;
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
    _communityCardControllers = List.generate(5, (_) =>
        AnimationController(
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
    _playerCardControllers = List.generate(2, (_) =>
        AnimationController(
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

  bool showPlayerCards = true;

  void _startAnimations() {
    // Start animations for community cards
    for (int i = 0; i < _communityCardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        _communityCardControllers[i].forward();
      });
    }

    // Start animations for player cards
    if (showPlayerCards) {
      for (int i = 0; i < _playerCardControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 200), () {
          _playerCardControllers[i].forward();
        });
      }

      // Start animations for opponent cards
      _player1CardController!.forward();
      _player2CardController!.forward();
      _player3CardController!.forward();
    }

    setState(() {
      showPlayerCards = true;
    });
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

  void onFold() {
    print('Fold button pressed');
    pokerGame.fold();
  }

  void onCheck() {
    print('Check button pressed');
    pokerGame.check();
  }

  void onCall() {
    print('Call button pressed');
    pokerGame.call();
  }

  void onRaise1() {
    print('Raise1 button pressed');
    pokerGame.raiseS();
  }

  void onRaise2() {
    print('Raise2 button pressed');
    pokerGame.raiseP();
  }

  void onRaise3() {
    print('Raise3 button pressed');
    pokerGame.raiseA();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 130, 37, 37),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 158, 110, 110),
        title: const Text('Table'),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              setState(() {
                pokerGame.roundEnd();
                if (pokerGame.revealState == 0) {
                  // Reveal the first 3 cards simultaneously
                  for (int i = 0; i < 3; i++) {
                    _communityCardControllers[i].forward();
                  }
                  pokerGame.revealState = 3;
                } else
                if (pokerGame.revealState >= 3 && pokerGame.revealState < 5) {
                  // Reveal the next card
                  _communityCardControllers[pokerGame.revealState].forward();
                  pokerGame.revealState++;
                }
              });
            },
          ),
        ],
      ),
      body: Stack(

        children: [
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
                    Text(
                      'Player 2 - \$${pokerGame.players[2].stack}',
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
                        Text(
                          'Player 1 - \$${pokerGame.players[1].stack}',
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
                  Column(
                    children: [
                      Text('Pot - \$${pokerGame.potValue}',
                          style: TextStyle(color: Colors.white)),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: pokerGame.communityCards
                            .asMap()
                            .entries
                            .map((entry) {
                          int idx = entry.key;
                          var card = entry.value;
                          Widget cardWidget;
                          if (idx < pokerGame.revealState) {
                            cardWidget = CachedNetworkImage(
                              imageUrl: card.image,
                              width: 40,
                              height: 60,
                              placeholder: (context,
                                  url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                            );
                          } else {
                            cardWidget = const Image(
                              image: AssetImage('assets/card_back.png'),
                              width: 40,
                              height: 60,
                            );
                          }
                          return SlideTransition(
                            position: _communityCardAnimations[idx],
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: cardWidget,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),


                  // Player 3 (right of community cards)
                  if (_player3CardAnimation != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Player 3 - \$${pokerGame.players[3].stack}',
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
                  Text(
                    'You - \$${pokerGame.players[0].stack}',
                    style: TextStyle(color: Colors.white),
                  ),

                  const SizedBox(height: 1),


                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: onFold,
                        child: const Text('Fold'),
                      ),


                      ElevatedButton(
                        onPressed: onCheck,
                        child: const Text('Check'),
                      ),


                      ElevatedButton(
                        onPressed: onCall,
                        child: const Text('Call'),
                      ),

                      const Spacer(),

                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: pokerGame.players
                                .firstWhere((player) => player.isHuman)
                                .cards
                                .asMap()
                                .entries
                                .map((entry) {
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
                                    placeholder: (context,
                                        url) => const CircularProgressIndicator(),
                                    errorWidget: (context, url,
                                        error) => const Icon(Icons.error),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      const Spacer(),

                      ElevatedButton(
                        onPressed: onRaise1,
                        child: const Text('Raise 50'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(72, 36),
                        ),
                      ),


                      ElevatedButton(
                        onPressed: onRaise2,
                        child: const Text('Raise 150'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(72, 36),
                        ),
                      ),


                      ElevatedButton(
                        onPressed: onRaise3,
                        child: const Text('All in'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(72, 36),
                        ),
                      ),
                    ],
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