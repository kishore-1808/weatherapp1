import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: MainPage()));
}

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.blueAccent,
            height: MediaQuery.of(context).size.height / 2,
            width: double.infinity,
            child: Center(
              child: MaterialButton(
                color: Colors.white,
                height: 150,
                minWidth: 150,
                shape: const CircleBorder(),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GamePage()),
                  );
                },
                child: const Text("START"),
              ),
            ),
          ),
          Container(
            color: Colors.redAccent,
            height: MediaQuery.of(context).size.height / 2,
            width: double.infinity,
            child: Center(
              child: MaterialButton(
                color: Colors.white,
                height: 150,
                minWidth: 150,
                shape: const CircleBorder(),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GamePage()),
                  );
                },
                child: const Text("START"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int scoreA = 0;
  int scoreB = 0;

  double flexA = 1;
  double flexB = 1;

  final int winningPoint = 10;

  void increaseBlue() {
    setState(() {
      scoreA++;
      flexA++;
      if (flexB > 1) flexB--;
      if (scoreA >= winningPoint) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ResultPage(player: "Player A", score: scoreA, color: Colors.blueAccent),
          ),
        );
      }
    });
  }

  void increaseRed() {
    setState(() {
      scoreB++;
      flexB++;
      if (flexA > 1) flexA--;
      if (scoreB >= winningPoint) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ResultPage(player: "Player B", score: scoreB, color: Colors.redAccent),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: flexA.toInt(),
            child: GestureDetector(
              onTap: increaseBlue,
              child: Container(
                width: double.infinity,
                color: Colors.blueAccent,
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Player A",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    Text(
                      "$scoreA",
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: flexB.toInt(),
            child: GestureDetector(
              onTap: increaseRed,
              child: Container(
                width: double.infinity,
                color: Colors.redAccent,
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Expanded(
                      child: Text(
                        "Player B",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    Text(
                      "$scoreB",
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final String player;
  final int score;
  final Color color;

  const ResultPage({Key? key, required this.player, required this.score, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$player Wins!",
              style: const TextStyle(
                  fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              "Score: $score",
              style: const TextStyle(
                  fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainPage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: color,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("Restart"),
            ),
          ],
        ),
      ),
    );
  }
}
