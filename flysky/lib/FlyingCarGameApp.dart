import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'dart:async';

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
  double airplaneYPosition = 300.0;
  double airplaneXPosition = 100.0;
  double velocity = 0.0;
  final double gravity = 0.5;
  final double jumpStrength = -10.0;
  bool isGameOver = false;
  int score = 0;
  int points = 0;

  // Obstacles
  List<Obstacle> obstacles = [];
  List<PointItem> pointItems = [];
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
      airplaneYPosition = 300.0;
      velocity = 0.0;
      isGameOver = false;
      score = 0;
      points = 0;
      obstacles.clear();
      pointItems.clear();
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

    // Spawn point items periodically
    Timer.periodic(Duration(seconds: 3), (timer) {
      if (!isGameOver) {
        spawnPointItem();
      } else {
        timer.cancel();
      }
    });
  }

  void updateGame() {
    setState(() {
      // Apply gravity
      velocity += gravity;
      airplaneYPosition += velocity;

      // Check for ground collision
      if (airplaneYPosition >= MediaQuery.of(context).size.height - 100) {
        airplaneYPosition = MediaQuery.of(context).size.height - 100;
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

      // Move and remove point items
      pointItems.removeWhere((pointItem) {
        pointItem.xPosition -= 5;
        
        // Check point collection
        if (isPointCollection(pointItem)) {
          points += 10;
        }

        return pointItem.xPosition < -50;
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

  void spawnPointItem() {
    setState(() {
      pointItems.add(PointItem(
        xPosition: MediaQuery.of(context).size.width,
        yPosition: random.nextDouble() * (MediaQuery.of(context).size.height - 200) + 100,
        size: 30,
      ));
    });
  }

  bool isCollision(Obstacle obstacle) {
    return airplaneXPosition < obstacle.xPosition + obstacle.width &&
        airplaneXPosition + 50 > obstacle.xPosition &&
        airplaneYPosition < obstacle.height;
  }

  bool isPointCollection(PointItem pointItem) {
    return airplaneXPosition < pointItem.xPosition + pointItem.size &&
        airplaneXPosition + 50 > pointItem.xPosition &&
        airplaneYPosition < pointItem.yPosition + pointItem.size &&
        airplaneYPosition + 50 > pointItem.yPosition;
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
              // Airplane
              Positioned(
                left: airplaneXPosition,
                top: airplaneYPosition,
                child: Icon(
                  LucideIcons.plane,
                  size: 50,
                  color: Colors.blue[800],
                ),
              ),

              // Obstaclesdd
              ...obstacles.map((obstacle) => Positioned(
                    left: obstacle.xPosition,
                    top: 0,
                    child: Container(
                      width: obstacle.width,
                      height: obstacle.height,
                      color: Colors.green,
                    ),
                  )),

              // Point Items
              ...pointItems.map((pointItem) => Positioned(
                    left: pointItem.xPosition,
                    top: pointItem.yPosition,
                    child: Container(
                      width: pointItem.size,
                      height: pointItem.size,
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )),

              // Scores
              Positioned(
                top: 50,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distance: $score',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Points: $points',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow[700],
                      ),
                    ),
                  ],
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
                      Text(
                        'Total Points: $points',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
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

class PointItem {
  double xPosition;
  double yPosition;
  double size;

  PointItem({
    required this.xPosition,
    required this.yPosition,
    required this.size,
  });
}
