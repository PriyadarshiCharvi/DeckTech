import 'package:flutter/material.dart';
import 'package:decktech/screens/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 130, 37, 37),
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0, // No shadow
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.portrait);
            },
            icon: const Icon(Icons.logout),
            color: Colors.red,
          ),
          const SizedBox(width: 10), // Adjust width as needed for spacing
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                const Text(
                  'DeckTech',
                  style: TextStyle(
                    color: Color.fromARGB(255, 208, 135, 135),
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Arial', // Replace with your desired font family
                  ),
                ),
                const SizedBox(height: 20),

                // Options
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.rotating);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 158, 110, 110), // Text color
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Arial', // Replace with your desired font family
                    ),
                  ),
                  child: const Text('Create New Game'),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    // Add functionality for joining existing game
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 158, 110, 110), // Text color
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Arial', // Replace with your desired font family
                    ),
                  ),
                  child: const Text('Join Existing Game'),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.landscape2);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 158, 110, 110), // Text color
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Arial', // Replace with your desired font family
                    ),
                  ),
                  child: const Text('Spectate Game'),
                ),
                const SizedBox(height: 50),

                // Additional content as per your design
              ],
            ),
          ),
        ),
      ),
    );
  }
}
