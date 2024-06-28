import 'package:decktech/gameplay/poker_game.dart';
import 'package:decktech/models/player_model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SpectateScreen extends StatefulWidget {
  const SpectateScreen({super.key});

  @override
  _SpectateScreenState createState() => _SpectateScreenState();
}

class _SpectateScreenState extends State<SpectateScreen> with TickerProviderStateMixin {
  late PokerGame pokerGame;
  bool isLoading = true;

  late List<AnimationController> _communityCardControllers;
  late List<Animation<Offset>> _communityCardAnimations;

  late List<AnimationController> _playerCardControllers;
  late List<Animation<Offset>> _playerCardAnimations;

  @override
  void initState() {
    super.initState();
    pokerGame = PokerGame();
    pokerGame.players = [
      PlayerModel(name: 'Computer 1'),
      PlayerModel(name: 'Computer 2'),
      PlayerModel(name: 'Computer 3'),
      PlayerModel(name: 'Computer 4'),
    ];

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

    _playerCardControllers = List.generate(4, (_) => AnimationController(
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

    pokerGame.startGame().then((_) {
      setState(() {
        isLoading = false;
        _startAnimations();
      });
    });
  }

  void _startAnimations() {
    for (int i = 0; i < _communityCardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        _communityCardControllers[i].forward();
      });
    }

    for (int i = 0; i < _playerCardControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        _playerCardControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _communityCardControllers) {
      controller.dispose();
    }
    for (var controller in _playerCardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 130, 37, 37),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 158, 110, 110),
        title: const Text('Spectate Mode'),
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
                            'Player 3',
                            style: TextStyle(color: Colors.white),
                          ),
                          SlideTransition(
                            position: _playerCardAnimations[0],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: pokerGame.players[0].cards.map((card) {
                                return Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: CachedNetworkImage(
                                    imageUrl: card.image,
                                    width: 40,
                                    height: 60,
                                    placeholder: (context, url) => const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Player 2',
                              style: TextStyle(color: Colors.white),
                            ),
                            SlideTransition(
                              position: _playerCardAnimations[1],
                              child: Row(
                                children: pokerGame.players[1].cards.map((card) {
                                  return Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: CachedNetworkImage(
                                      imageUrl: card.image,
                                      width: 40,
                                      height: 60,
                                      placeholder: (context, url) => const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Player 4',
                              style: TextStyle(color: Colors.white),
                            ),
                            SlideTransition(
                              position: _playerCardAnimations[2],
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: pokerGame.players[2].cards.map((card) {
                                  return Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: CachedNetworkImage(
                                      imageUrl: card.image,
                                      width: 40,
                                      height: 60,
                                      placeholder: (context, url) => const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Player 1',
                            style: TextStyle(color: Colors.white),
                          ),
                          SlideTransition(
                            position: _playerCardAnimations[3],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: pokerGame.players[3].cards.map((card) {
                                return Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: CachedNetworkImage(
                                    imageUrl: card.image,
                                    width: 40,
                                    height: 60,
                                    placeholder: (context, url) => const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
