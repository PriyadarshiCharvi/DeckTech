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
  late PokerGame game;
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
    game = PokerGame();
    game.players = [
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
        begin: const Offset(0, -4),
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
      begin: const Offset(-3, 0), // Left
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
      begin: const Offset(0, -3), // Above
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
      begin: const Offset(0, -3), // Above
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
      begin: const Offset(0, -3), // Above
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
      begin: const Offset(3, 0), // To the right
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _player5CardController!,
      curve: Curves.easeOut,
    ));

    game.startGame().then((_) {
      setState(() {
        isLoading = false;
        _startAnimations();
      });
    });
    takeBlinds();
  }

  takeBlinds() {
    for (PlayerModel player in game.players) {
      if (player.position == 1) { //SMALL BLIND
        player.stack -= 1;
        player.hasBet += 1;
        player.actedThisRound = true;
      } else if (player.position == 2) { //BIG BLIND
        player.stack -= 2;
        player.hasBet += 2;
        player.actedThisRound = true;
        game.roundBet = 2;
      }
    }
    for (int playerIndex = 0; playerIndex < 6; playerIndex++) {
      if (game.players[playerIndex].position == 3) {
        game.currentPlayerIndex = playerIndex;
      }
    }
  }

  bool showPlayerCards = true;

  static const String cardBack = 'assets/card_back.png';

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

  void revealComCards() {
    setState(() {
      for (var player in game.players) {
        if (!player.isHuman) {
          player.showCards = true;
        }
      }
    });
  }

  void hideComCards() {
    setState(() {
      for (var player in game.players) {
        if (!player.isHuman) {
          player.showCards = false;
        }
      }
    });
  }

  void resetGame() {
    setState(() {
      for (var controller in _communityCardControllers) {controller.reset();}
      for (var controller in _playerCardControllers) {controller.reset();}
      _player1CardController?.reset();
      _player2CardController?.reset();
      _player3CardController?.reset();
      _player4CardController?.reset();
      _player5CardController?.reset();
      hideComCards();

      for (int playerIndex = 0; playerIndex < 6; playerIndex++) {
        PlayerModel player = game.players[playerIndex];
        player.actedThisRound = false;
        player.isAllIn = false;
        if (player.stack == 0) {
          player.hasFolded = true;
        } else {
          player.hasFolded = false;
        }
      }

      game.shiftPositions();
      game.startGame().then((_) {
        game.revealState = 0;
        _startAnimations();
      });
      takeBlinds();
    });
  }

  Future<void> roundEnd() async{
    for (int playerIndex = 0; playerIndex < 6; playerIndex++) {
      PlayerModel player = game.players[playerIndex];
      game.pot += player.hasBet;
      player.hasBet = 0;
      if (!player.isAllIn && !player.hasFolded) {
        player.actedThisRound = false;
      }
    }
    game.roundBet = 0;
    print("-------------BETTING ROUND COMPLETE-------------");
    if (game.isBettingComplete()) {
      nextButtonLogic;
    } else {
      for (int playerIndex = 0; playerIndex < 6; playerIndex++) {
        if (game.players[playerIndex].position == 1) {
          game.currentPlayerIndex = playerIndex;
          while (true) {
            if (game.currentPlayerCannotAct()) {
              game.shiftPlayerIndex();
            } else {
              break;
            }
          }
        }
      }
    }
  }

  nextButtonLogic() {
    //CHECK IF ONLY ONE PLAYER LEFT IN HAND
    List<PlayerModel> inHand = [];
    for (PlayerModel player in game.players) {
      if (!player.hasFolded) {
        inHand.add(player);
      }
    }
    if (inHand.length == 1) {
      game.revealState = 6;
      for (PlayerModel player in game.players) {
        game.pot += player.hasBet;
        player.hasBet = 0;
      }
      inHand[0].stack += game.pot;
      game.pot = 0;
      resetGame();
    }

    else if (game.isBettingComplete() || game.revealState >= 6) {
      roundEnd();
      switch (game.revealState) {
        case 0: //FLOP
          for (int i = 0; i < 3; i++) {
            _communityCardControllers[i].forward();
          }
          game.revealState = 3;
        case 3: //TURN
        case 4: //RIVER
          _communityCardControllers[game.revealState].forward();
          game.revealState++;
        case 5: //REVEAL COM CARDS
          revealComCards();
          game.revealState++;
        case 6: //SHOWDOWN
          if (inHand.length == 1) {
            inHand[0].stack += game.pot;
          } else {
            List winners = game.getWinningPlayers(inHand);
            if (winners.length > 1) {
              game.splitPot(winners, inHand);
            } else {
              inHand[winners[0]].stack += game.pot;
            }
          }
          game.pot = 0;
          game.revealState++;
        case 7:
          resetGame(); //RESET
      }
    }

    else {
      if (game.currentPlayerCannotAct()) {
        game.shiftPlayerIndex();
        nextButtonLogic();
      } else {
        game.computerActions();
        game.shiftPlayerIndex();
        while (true) {
          if (!game.isBettingComplete() && game.currentPlayerCannotAct()) {
            game.shiftPlayerIndex();
          } else {
            break;
          }
        }
      }
    }
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
                    onPressed: () {Navigator.pop(context);},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      fixedSize: const Size(90, 36),
                    ),
                    child: const Text('EXIT', style: TextStyle(fontSize: 14, color: Colors.white)),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(6),
                  child: ElevatedButton(
                    onPressed: () {setState(() {
                        if (game.currentPlayerIndex == 0) {
                          if (!game.currentPlayerCannotAct()) {
                            print("Action on you");
                          } else {
                            nextButtonLogic();
                          }
                        } else {
                          nextButtonLogic();
                        }
                    });},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      fixedSize: const Size(90, 36),
                    ),
                    child: const Text('NEXT', style: TextStyle(fontSize: 14, color: Colors.white)),
                  ),
                ),
            ]),
          ),

          // ALL PLAYERS AND ACTIONS BUTTONS

          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // PLAYER 2, PLAYER 3 and PLAYER 4 (above community cards)

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  // PLAYER 2 (top left of community cards)

                  if (_player2CardAnimation != null)
                    Column(
                      children: [
                        Text(
                          (game.players[2].position == 100)
                              ? 'COM2: OUT'
                              : '${game.players[2].position}. COM2: \$${game.players[2].stack}-\$${game.players[2].hasBet}'
                          ,
                          // style: (!game.players[2].hasFolded && (game.currentPlayerIndex == 2 || (game.currentPlayerIndex == 1 && game.players[1].hasFolded)))
                          style: (game.currentPlayerIndex == 2)
                              ? const TextStyle(fontSize: 17, color: Colors.yellow, fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black, blurRadius: 12,)],)
                              : const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black, blurRadius: 12,)],),
                        ),
                        SlideTransition(
                          position: _player2CardAnimation!,
                          child: Row(mainAxisAlignment: MainAxisAlignment.end,
                              children: game.players[2].cards.map((card) {
                                return Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child:  game.players[2].showCards
                                      ? (game.players[2].hasFolded || (game.players[2].stack == 0 && !game.players[2].isAllIn))
                                      ? CachedNetworkImage(imageUrl: card.image, width: 60, height: 90, color: Colors.black38)
                                      : CachedNetworkImage(imageUrl: card.image, width: 60, height: 90)
                                      : (game.players[2].hasFolded || (game.players[2].stack == 0 && !game.players[2].isAllIn))
                                      ? Image.asset(cardBack, width: 50, height: 75, color: Colors.black38)
                                      : Image.asset(cardBack, width: 50, height: 75),
                                );
                              }).toList()
                          ),
                        ),
                      ],
                    ),

                  // PLAYER 3 (above community cards)

                  if (_player3CardAnimation != null)
                    Column(
                      children: [
                        Text(
                          (game.players[3].position == 100)
                              ? 'COM3: OUT'
                              : '${game.players[3].position}. COM3: \$${game.players[3].stack}-\$${game.players[3].hasBet}'
                          ,
                          // style: (!game.players[3].hasFolded && (game.currentPlayerIndex == 3 || (game.currentPlayerIndex == 2 && game.players[2].hasFolded)))
                          style: (game.currentPlayerIndex == 3)
                              ? const TextStyle(fontSize: 17, color: Colors.yellow, fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black, blurRadius: 12,)],)
                              : const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black, blurRadius: 12,)],),
                        ),
                        SlideTransition(
                          position: _player3CardAnimation!,
                          child: Row(mainAxisAlignment: MainAxisAlignment.end,
                              children: game.players[3].cards.map((card) {
                                return Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child:  game.players[3].showCards
                                      ? (game.players[3].hasFolded || (game.players[3].stack == 0 && !game.players[3].isAllIn))
                                      ? CachedNetworkImage(imageUrl: card.image, width: 60, height: 90, color: Colors.black38)
                                      : CachedNetworkImage(imageUrl: card.image, width: 60, height: 90)
                                      : (game.players[3].hasFolded || (game.players[3].stack == 0 && !game.players[3].isAllIn))
                                      ? Image.asset(cardBack, width: 50, height: 75, color: Colors.black38)
                                      : Image.asset(cardBack, width: 50, height: 75),
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
                          (game.players[4].position == 100)
                              ? 'COM4: OUT'
                              : '${game.players[4].position}. COM4: \$${game.players[4].stack}-\$${game.players[4].hasBet}'
                          ,
                          // style: (!game.players[4].hasFolded && (game.currentPlayerIndex == 4 || (game.currentPlayerIndex == 3 && game.players[3].hasFolded)))
                          style: (game.currentPlayerIndex == 4)
                              ? const TextStyle(fontSize: 17, color: Colors.yellow, fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black, blurRadius: 12,)],)
                              : const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black, blurRadius: 12,)],),
                        ),
                        SlideTransition(
                          position: _player4CardAnimation!,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: game.players[4].cards.map((card) {
                                return Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child:  game.players[4].showCards
                                      ? (game.players[4].hasFolded || (game.players[4].stack == 0 && !game.players[4].isAllIn))
                                      ? CachedNetworkImage(imageUrl: card.image, width: 60, height: 90, color: Colors.black38)
                                      : CachedNetworkImage(imageUrl: card.image, width: 60, height: 90)
                                      : (game.players[4].hasFolded || (game.players[4].stack == 0 && !game.players[4].isAllIn))
                                      ? Image.asset(cardBack, width: 50, height: 75, color: Colors.black38)
                                      : Image.asset(cardBack, width: 50, height: 75),
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
                          (game.players[1].position == 100)
                              ? 'COM1: OUT'
                              : '${game.players[1].position}. COM1: \$${game.players[1].stack}-\$${game.players[1].hasBet}'
                          ,
                          // style: (!game.players[1].hasFolded && (game.currentPlayerIndex == 1 || (game.currentPlayerIndex == 0 && game.players[0].hasFolded)))
                          style: (game.currentPlayerIndex == 1)
                              ? const TextStyle(fontSize: 17, color: Colors.yellow, fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black, blurRadius: 12,)],)
                              : const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black, blurRadius: 12,)],),
                        ),
                        SlideTransition(
                          position: _player1CardAnimation!,
                          child: Row(mainAxisAlignment: MainAxisAlignment.end,
                            children: game.players[1].cards.map((card) {
                              return Padding(
                                padding: const EdgeInsets.all(2.0),
                                child:  game.players[1].showCards
                                    ? (game.players[1].hasFolded || (game.players[1].stack == 0 && !game.players[1].isAllIn))
                                    ? CachedNetworkImage(imageUrl: card.image, width: 60, height: 90, color: Colors.black38)
                                    : CachedNetworkImage(imageUrl: card.image, width: 60, height: 90)
                                    : (game.players[1].hasFolded || (game.players[1].stack == 0 && !game.players[1].isAllIn))
                                    ? Image.asset(cardBack, width: 50, height: 75, color: Colors.black38)
                                    : Image.asset(cardBack, width: 50, height: 75),
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
                          'POT: \$${game.pot}', style: const TextStyle(fontSize: 17, color: Colors.white,
                          fontWeight: FontWeight.bold, shadows: [
                            Shadow(color: Colors.black, blurRadius: 12),
                          ],
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: game.communityCards
                            .asMap()
                            .entries
                            .map((entry) {
                          int index = entry.key;
                          var card = entry.value;

                          Widget cardWidget;
                          if (index < game.revealState) {
                            cardWidget = CachedNetworkImage(imageUrl: card.image, width: 50, height: 75);
                          } else {
                            cardWidget = const Image(image: AssetImage(cardBack), width: 50, height: 75);
                          }
                          return SlideTransition(
                            position: _communityCardAnimations[index],
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
                          (game.players[5].position == 100)
                              ? 'COM5: OUT'
                              : '${game.players[5].position}. COM5: \$${game.players[5].stack}-\$${game.players[5].hasBet}'
                          ,
                          // style: (!game.players[5].hasFolded && (game.currentPlayerIndex == 5 || (game.currentPlayerIndex == 4 && game.players[4].hasFolded)))
                          style: (game.currentPlayerIndex == 5)
                              ? const TextStyle(fontSize: 17, color: Colors.yellow, fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black, blurRadius: 12,)],)
                              : const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black, blurRadius: 12,)],),
                        ),
                        SlideTransition(
                          position: _player5CardAnimation!,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: game.players[5].cards.map((card) {
                              return Padding(
                                padding: const EdgeInsets.all(2.0),
                                child:  game.players[5].showCards
                                    ? (game.players[5].hasFolded || (game.players[5].stack == 0 && !game.players[5].isAllIn))
                                    ? CachedNetworkImage(imageUrl: card.image, width: 60, height: 90, color: Colors.black38)
                                    : CachedNetworkImage(imageUrl: card.image, width: 60, height: 90)
                                    : (game.players[5].hasFolded || (game.players[5].stack == 0 && !game.players[5].isAllIn))
                                    ? Image.asset(cardBack, width: 50, height: 75, color: Colors.black38)
                                    : Image.asset(cardBack, width: 50, height: 75),
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
                    (game.players[0].position == 100)
                        ? 'YOU: OUT'
                        : '${game.players[0].position}. YOU: \$${game.players[0].stack}-\$${game.players[0].hasBet}'
                    ,
                    // style: (!game.players[0].hasFolded && (game.currentPlayerIndex == 0 || (game.currentPlayerIndex == 5 && game.players[5].hasFolded)))
                    style: (game.currentPlayerIndex == 0)
                        ? const TextStyle(fontSize: 17, color: Colors.yellow, fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black, blurRadius: 12,)],)
                        : const TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black, blurRadius: 12,)],),
                  ),

                  Row(
                    children: [

                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: ElevatedButton(
                          onPressed:(){setState((){
                            print('Fold button pressed');
                            if (game.currentPlayerIndex != 0) {
                              print("Not your turn");
                            } else {
                              game.fold();
                              game.shiftPlayerIndex();
                              if (game.isBettingComplete()) {
                                nextButtonLogic;
                              } else {
                                while (true) {
                                  if (game.currentPlayerCannotAct()) {
                                    game.shiftPlayerIndex();
                                  } else {
                                    break;
                                  }
                                }
                              }
                            }
                          });},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white24,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fixedSize: const Size(109, 50),
                          ),
                          child: const Text(
                            'FOLD', style: TextStyle(fontSize: 15,
                              color: Colors.red, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: ElevatedButton(
                          onPressed:(){setState((){
                            print('Check button pressed');
                            if (game.currentPlayerIndex != 0) {
                              print("Not your turn");
                            } else if (game.roundBet != 0) {
                              print("Cannot check");
                            } else {
                              game.check();
                              game.shiftPlayerIndex();
                              if (game.isBettingComplete()) {
                                nextButtonLogic;
                              } else {
                                while (true) {
                                  if (game.currentPlayerCannotAct()) {
                                    game.shiftPlayerIndex();
                                  } else {
                                    break;
                                  }
                                }
                              }
                            }
                          });},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white24,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fixedSize: const Size(109, 50),
                          ),
                          child: const Text(
                              'CHECK', style: TextStyle(fontSize: 15,
                              color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: ElevatedButton(
                          onPressed:(){setState((){
                            print('Call button pressed');
                            if (game.currentPlayerIndex != 0) {
                              print("Not your turn");
                            } else {
                              game.call();
                              game.shiftPlayerIndex();
                              if (game.isBettingComplete()) {
                                nextButtonLogic;
                              } else {
                                while (true) {
                                  if (game.currentPlayerCannotAct()) {
                                    game.shiftPlayerIndex();
                                  } else {
                                    break;
                                  }
                                }
                              }
                            }
                          });},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white24,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fixedSize: const Size(109, 50),
                          ),
                          child: const Text(
                              'CALL', style: TextStyle(fontSize: 15,
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
                            children: game.players[0].cards
                                .asMap().entries.map((entry) {
                              int idx = entry.key;
                              var card = entry.value;
                              return SlideTransition(
                                position: _playerCardAnimations[idx],
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: (game.players[0].hasFolded || (game.players[0].stack == 0 && !game.players[0].isAllIn))
                                      ? CachedNetworkImage(imageUrl: card.image, width: 60, height: 90, color: Colors.black38)
                                      : CachedNetworkImage(imageUrl: card.image, width: 60, height: 90),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: ElevatedButton(
                          onPressed:(){setState((){
                            print('Bet small button pressed');
                            if (game.currentPlayerIndex != 0) {
                              print("Not your turn");
                            } else {
                              game.raiseSmall();
                              game.shiftPlayerIndex();
                              if (game.isBettingComplete()) {
                                nextButtonLogic;
                              } else {
                                while (true) {
                                  if (game.currentPlayerCannotAct()) {
                                    game.shiftPlayerIndex();
                                  } else {
                                    break;
                                  }
                                }
                              }
                            }
                          });},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white24,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fixedSize: const Size(129, 50),
                          ),
                          child: const Text(
                              'BET SMALL', style: TextStyle(fontSize: 15,
                              color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(0),
                        child: ElevatedButton(
                          onPressed:(){setState((){
                            print('Bet big button pressed');
                            if (game.currentPlayerIndex != 0) {
                              print("Not your turn");
                            } else {
                              game.raiseBig();
                              game.shiftPlayerIndex();
                              if (game.isBettingComplete()) {
                                nextButtonLogic;
                              } else {
                                while (true) {
                                  if (game.currentPlayerCannotAct()) {
                                    game.shiftPlayerIndex();
                                  } else {
                                    break;
                                  }
                                }
                              }
                            }
                          });},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white24,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fixedSize: const Size(104, 50),
                          ),
                          child: const Text(
                              'BET BIG', style: TextStyle(fontSize: 15,
                              color: Colors.white, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: ElevatedButton(
                          onPressed:(){setState((){
                            print('AllIn button pressed');
                            if (game.currentPlayerIndex != 0) {
                              print("Not your turn");
                            } else {
                              game.raiseAllIn();
                              game.shiftPlayerIndex();
                              if (game.isBettingComplete()) {
                                nextButtonLogic;
                              } else {
                                while (true) {
                                  if (game.currentPlayerCannotAct()) {
                                    game.shiftPlayerIndex();
                                  } else {
                                    break;
                                  }
                                }
                              }
                            }
                          });},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white24,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fixedSize: const Size(94, 50),
                          ),
                          child: const Text(
                              'ALL IN', style: TextStyle(fontSize: 15,
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