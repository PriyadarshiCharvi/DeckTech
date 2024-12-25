// ignore_for_file: avoid_print

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
  late List<AnimationController> _playerCardControllers;
  AnimationController? _player1CardController;
  AnimationController? _player2CardController;
  AnimationController? _player3CardController;
  AnimationController? _player4CardController;
  AnimationController? _player5CardController;

  late List<Animation<Offset>> _communityCardAnimations;
  late List<Animation<Offset>> _playerCardAnimations;
  Animation<Offset>? _player1CardAnimation;
  Animation<Offset>? _player2CardAnimation;
  Animation<Offset>? _player3CardAnimation;
  Animation<Offset>? _player4CardAnimation;
  Animation<Offset>? _player5CardAnimation;

 


  @override
  void initState() {
    super.initState();
    pokerGame = PokerGame();
    pokerGame.players = [
      PlayerModel(name: 'Player', position: 0, isHuman: true),
      PlayerModel(name: 'COM 1', position: 1),
      PlayerModel(name: 'COM 2', position: 2),
      PlayerModel(name: 'COM 3', position: 3),
      PlayerModel(name: 'COM 4', position: 4),
      PlayerModel(name: 'COM 5', position: 5),
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

    // INITIALIZE ANIMATION CONTROLLERS AND ANIMATIONS

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
      begin: const Offset(0, -3), // Off-screen above
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _player3CardController!,
      curve: Curves.easeOut,
    ));

    _player4CardController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _player4CardAnimation = Tween<Offset>(
      begin: const Offset(0, -3), // Off-screen above
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _player4CardController!,
      curve: Curves.easeOut,
    ));

    _player5CardController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _player5CardAnimation = Tween<Offset>(
      begin: const Offset(3, 0), // Off-screen to the right
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _player5CardController!,
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
      _player4CardController!.forward();
      _player5CardController!.forward();
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
    _player4CardController?.dispose();
    _player5CardController?.dispose();
    super.dispose();
  }

  void refreshStacksAndPots() {
    setState(() {
    });
  }

  void onFold() {
    print('Fold button pressed');
    if (pokerGame.currentPlayerIndex != 0) {
      print("It is not your turn");
    } else {
      pokerGame.fold();
    }
  }

  void onCheck() {
    print('Check button pressed');
    if (pokerGame.currentPlayerIndex != 0) {
      print("It is not your turn");
    } else {
      pokerGame.check();
    }
  }

  void onCall() {
    print('Call button pressed');
    if (pokerGame.currentPlayerIndex != 0) {
      print("It is not your turn");
    } else {
      pokerGame.callLogic();
    }
  }

  void onRaise5() {
    print('Raise5 button pressed');
    if (pokerGame.currentPlayerIndex != 0) {
      print("It is not your turn");
    } else {
      pokerGame.raise5();
    }
  }

  void onRaise20() {
    print('Raise20 button pressed');
    if (pokerGame.currentPlayerIndex != 0) {
      print("It is not your turn");
    } else {
      pokerGame.raise20();
    }
  }

  void onAllIn() {
    print('AllIn button pressed');
    if (pokerGame.currentPlayerIndex != 0) {
      print("It is not your turn");
    } else {
      pokerGame.raiseAllIn();
    }
  }

  void revealAllComputerCards() {
    setState(() {
      for (var player in pokerGame.players) {
        if (!player.isHuman) {
          player.showCards = true;
        }
      }
    });
  }

  void hideAllComputerCards() {
    setState(() {
      for (var player in pokerGame.players) {
        if (!player.isHuman) {
          player.showCards = false;
        }
      }
    });
  }

  int revealState = 0;

  void resetGameAndDealNewCards() {
    setState(() {
      for (var controller in _communityCardControllers) {
        controller.reset();
      }
      for (var controller in _playerCardControllers) {
        controller.reset();
      }
      _player1CardController?.reset();
      _player2CardController?.reset();
      _player3CardController?.reset();
      _player4CardController?.reset();
      _player5CardController?.reset();
      hideAllComputerCards();

      pokerGame.startGame().then((_) {
        revealState = 0;
        _startAnimations();
      });
    });
  }
   

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          //BACKGROUND

          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/backdrop.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          //NAVIGATION BUTTONS

          SizedBox(
            height: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Padding(
                  padding: const EdgeInsets.all(6),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      fixedSize: const Size(90, 36),
                    ),
                    child: const Text(
                        'EXIT', style: TextStyle(fontSize: 14,
                        color: Colors.white,
                        //fontWeight: FontWeight.bold
                    )
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(6),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (pokerGame.isBettingRoundComplete()) {
                          pokerGame.roundEnd();
                          if (revealState == 0) {
                            for (int i = 0; i < 3; i++) {
                              _communityCardControllers[i].forward();
                              print("------ACTION ON YOU------");
                            }
                            revealState = 3; //FLOP
                          } else if (revealState >= 3 && revealState < 5) {
                            _communityCardControllers[revealState].forward();
                            revealState++; //TURN AND RIVER
                            print("------ACTION ON YOU------");
                          } else if (revealState == 5) {
                            revealAllComputerCards();
                            revealState++; //SHOWDOWN
                          } else {
                            //NEED TO IMPLEMENT SHOWDOWN
                            resetGameAndDealNewCards(); //ROUND END
                          }
                        } else {
                          pokerGame.nextPlayer();
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      fixedSize: const Size(90, 36),
                    ),
                    child: const Text(
                        'NEXT', style: TextStyle(fontSize: 14,
                      color: Colors.white,
                      //fontWeight: FontWeight.bold
                    )
                    ),
                  ),
                ),

            ]),
          ),

          // ALL PLAYERS AND ACTIONS BUTTONS

          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // PLAYER 2 (above community cards)

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  // PLAYER 2 (top left of community cards)

                  if (_player2CardAnimation != null)
                    Column(
                      children: [
                        Text(
                          'COM 2: \$${pokerGame.players[2].stack}',
                          style: const TextStyle(fontSize: 17, color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        SlideTransition(
                          position: _player2CardAnimation!,
                          child: Row(mainAxisAlignment: MainAxisAlignment.end,
                              children: pokerGame.players[2].cards.map((card) {
                                return Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: pokerGame.players[2].showCards
                                      ? CachedNetworkImage(imageUrl: card.image, width: 50, height: 75)
                                      : Image.asset('assets/card_back.png', width: 50, height: 75),
                                );
                              }).toList()
                          ),
                        ),
                      ],
                    ),

                  // PLAYER 3 (top of community cards)

                  if (_player3CardAnimation != null)
                    Column(
                      children: [
                        Text(
                          'COM 3: \$${pokerGame.players[3].stack}',
                          style: const TextStyle(fontSize: 17, color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        SlideTransition(
                          position: _player3CardAnimation!,
                          child: Row(mainAxisAlignment: MainAxisAlignment.end,
                              children: pokerGame.players[3].cards.map((card) {
                                return Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: pokerGame.players[3].showCards
                                      ? CachedNetworkImage(imageUrl: card.image, width: 50, height: 75)
                                      : Image.asset('assets/card_back.png', width: 50, height: 75),
                                );
                              }).toList()
                          ),
                        ),
                      ],
                    ),

                  // PLAYER 4 (top right of community cards)

                  if (_player4CardAnimation != null)
                    Column(
                      children: [
                        Text(
                          'COM 4: \$${pokerGame.players[4].stack}',
                          style: const TextStyle(fontSize: 17, color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        SlideTransition(
                          position: _player4CardAnimation!,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: pokerGame.players[4].cards.map((card) {
                                return Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: pokerGame.players[4].showCards
                                      ? CachedNetworkImage(imageUrl: card.image, width: 50, height: 75)
                                      : Image.asset('assets/card_back.png', width: 50, height: 75),
                                );
                              }).toList()
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              //PLAYER 1, COMMUNITY CARDS, PLAYER 5

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [

                  // PLAYER 1 (left of community cards)

                  if (_player1CardAnimation != null)
                    Column(
                      children: [
                        Text(
                          'COM 1: \$${pokerGame.players[1].stack}',
                          style: const TextStyle(fontSize: 17, color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        SlideTransition(
                          position: _player1CardAnimation!,
                          child: Row(mainAxisAlignment: MainAxisAlignment.end,
                            children: pokerGame.players[1].cards.map((card) {
                              return Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: pokerGame.players[1].showCards
                                ? CachedNetworkImage(imageUrl: card.image, width: 50, height: 75)
                                : Image.asset('assets/card_back.png', width: 50, height: 75),
                              );
                            }).toList()
                          ),
                        ),
                      ],
                    ),

                  //POT AND COMMUNITY CARDS

                  Column(
                    children: [
                      Text(
                          'POT: \$${pokerGame.pot}', style: const TextStyle(fontSize: 17, color: Colors.white,
                          fontWeight: FontWeight.bold, shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 12,
                            ),
                          ],
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: pokerGame.communityCards
                            .asMap()
                            .entries
                            .map((entry) {
                          int idx = entry.key;
                          var card = entry.value;

                          Widget cardWidget;
                          if (idx < revealState) {
                            cardWidget = CachedNetworkImage(imageUrl: card.image, width: 50, height: 75);
                          } else {
                            cardWidget = const Image(image: AssetImage('assets/card_back.png'), width: 50, height: 75);
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

                  // PLAYER 5 (right of community cards)

                  if (_player5CardAnimation != null)
                    Column(
                      children: [
                        Text(
                          'COM 5: \$${pokerGame.players[5].stack}',
                          style: const TextStyle(fontSize: 17, color: Colors.white,
                          fontWeight: FontWeight.bold),
                        ),
                        SlideTransition(
                          position: _player5CardAnimation!,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: pokerGame.players[5].cards.map((card) {
                              return Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: pokerGame.players[5].showCards
                                  ? CachedNetworkImage(imageUrl: card.image, width: 50, height: 75)
                                  : Image.asset('assets/card_back.png', width: 50, height: 75),
                              );
                            }).toList()
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // ACTION BUTTONS AND USER PLAYER

              Column(
                children: [
                  Text(
                    'YOU: \$${pokerGame.players[0].stack}',
                    style: const TextStyle(fontSize: 17, color: Colors.white,
                        fontWeight: FontWeight.bold, shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 12,
                        )
                      ],
                    ),
                  ),

                  Row(
                    children: [

                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: ElevatedButton(
                          onPressed:(){setState((){onFold();});},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white24,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fixedSize: const Size(113, 50),
                          ),
                          child: const Text(
                            'FOLD', style: TextStyle(fontSize: 16,
                              color: Colors.red, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: ElevatedButton(
                          onPressed:(){setState((){onCheck();});},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white24,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fixedSize: const Size(113, 50),
                          ),
                          child: const Text(
                              'CHECK', style: TextStyle(fontSize: 16,
                              color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: ElevatedButton(
                          onPressed:(){setState((){onCall();});},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white24,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fixedSize: const Size(113, 50),
                          ),
                          child: const Text(
                              'CALL', style: TextStyle(fontSize: 16,
                              color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),

                      //USER PLAYER

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
                                  child: CachedNetworkImage(imageUrl: card.image, width: 60, height: 90)
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: ElevatedButton(
                          onPressed:(){setState((){onRaise5();});},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white24,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fixedSize: const Size(116, 50),
                          ),
                          child: const Text(
                              'RAISE 5', style: TextStyle(fontSize: 16,
                              color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: ElevatedButton(
                          onPressed:(){setState((){onRaise20();});},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white24,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fixedSize: const Size(116, 50),
                          ),
                          child: const Text(
                              'RAISE 20', style: TextStyle(fontSize: 16,
                              color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: ElevatedButton(
                          onPressed:(){setState((){onAllIn();});},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white24,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fixedSize: const Size(107, 50),
                          ),
                          child: const Text(
                              'ALL IN', style: TextStyle(fontSize: 16,
                              color: Colors.white, fontWeight: FontWeight.bold)
                          ),
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