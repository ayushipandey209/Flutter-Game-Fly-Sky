import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlyingCarGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flying Car Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Game variables
  double carYPosition = 300.0;
  double carXPosition = 100.0;
  double velocity = 0.0;
  final double gravity = 0.5;
  final double jumpStrength = -10.0;
  bool isGameOver = false;
  int score = 0;

  // Obstacles
  List<Obstacle> obstacles = [];
  final Random random = Random();

  // Game loop and timer
  late Timer gameTimer;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    // Reset game state
    setState(() {
      carYPosition = 300.0;
      velocity = 0.0;
      isGameOver = false;
      score = 0;
      obstacles.clear();
    });

    // Start game loop
    gameTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (!isGameOver) {
        updateGame();
      } else {
        timer.cancel();
      }
    });

    // Spawn obstacles periodically
    Timer.periodic(Duration(seconds: 2), (timer) {
      if (!isGameOver) {
        spawnObstacle();
      } else {
        timer.cancel();
      }
    });
  }

  void updateGame() {
    setState(() {
      // Apply gravity
      velocity += gravity;
      carYPosition += velocity;

      // Check for ground collision
      if (carYPosition >= MediaQuery.of(context).size.height - 100) {
        carYPosition = MediaQuery.of(context).size.height - 100;
        velocity = 0.0;
      }

      // Move and remove obstacles
      obstacles.removeWhere((obstacle) {
        obstacle.xPosition -= 5;
        
        // Check collision
        if (isCollision(obstacle)) {
          gameOver();
        }

        return obstacle.xPosition < -50;
      });

      // Increment score
      score++;
    });
  }

  void spawnObstacle() {
    setState(() {
      obstacles.add(Obstacle(
        xPosition: MediaQuery.of(context).size.width,
        height: random.nextDouble() * 200 + 50,
        width: 50,
      ));
    });
  }

  bool isCollision(Obstacle obstacle) {
    // Simple rectangular collision detection
    return carXPosition < obstacle.xPosition + obstacle.width &&
        carXPosition + 50 > obstacle.xPosition &&
        carYPosition < obstacle.height;
  }

  void jump() {
    if (!isGameOver) {
      setState(() {
        velocity = jumpStrength;
      });
    }
  }

  void gameOver() {
    setState(() {
      isGameOver = true;
    });
    gameTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: jump,
        child: Container(
          color: Colors.blue[100],
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Car
              Positioned(
                left: carXPosition,
                top: carYPosition,
                child: Container(
                  width: 50,
                  height: 30,
                  color: Colors.red,
                ),
              ),

              // Obstacles
              ...obstacles.map((obstacle) => Positioned(
                    left: obstacle.xPosition,
                    top: 0,
                    child: Container(
                      width: obstacle.width,
                      height: obstacle.height,
                      color: Colors.green,
                    ),
                  )),

              // Score
              Positioned(
                top: 50,
                left: 20,
                child: Text(
                  'Score: $score',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Game Over
              if (isGameOver)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Game Over',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: startGame,
                        child: Text('Restart'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    gameTimer.cancel();
    super.dispose();
  }
}

class Obstacle {
  double xPosition;
  double height;
  double width;

  Obstacle({
    required this.xPosition,
    required this.height,
    required this.width,
  });
}
