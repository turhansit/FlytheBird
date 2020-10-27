import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutters/components/background.dart';
import 'package:flutters/components/bird.dart';
import 'package:flutters/components/dialog.dart';
import 'package:flutters/components/floor.dart';
import 'package:flutters/components/level.dart';
import 'package:flutters/components/obstacle.dart';
import 'package:flutters/components/text.dart';
import 'package:flutters/services/notification.dart';
import 'package:flutters/services/advert_services.dart';

enum GameState {
  playing,
  gameOver,
}


class FluttersGame extends Game {
  final  AdvertService _advertService= AdvertService();
  final pushNotificationsServices _pns = pushNotificationsServices();
  GameState currentGameState = GameState.playing;
  Size viewport;
  Background skyBackground;

  Floor groundFloor;
  Level currentLevel;
  Bird birdPlayer;
  TextComponent scoreText;
  TextComponent floorText;
  Dialog gameOverDialog;

  double tileSize;
  double birdPosY;
  double birdPosYOffset = 8;
  bool isBirding = false;
  double birdChangeValue = 1;
  double birdValue = 0;
  double flutterIntensity = 5.0;
  double floorHeight = 150;
  // Game Score
  double currentHeight = 0;

  FluttersGame(screenDimensions) {
    resize(screenDimensions);

    skyBackground = Background(this, 0, 0, viewport.width, viewport.height);
    groundFloor = Floor(this, 0, viewport.height - floorHeight, viewport.width,
        floorHeight, 0xff48BB78);
    currentLevel = Level(this);
    birdPlayer = Bird(this, 0, birdPosY, tileSize, tileSize);
    scoreText = TextComponent(this, '0', 30.0, 60.0);
    floorText = TextComponent(
        this, 'Fly the bird!', 40.0, viewport.height - floorHeight / 2);
    gameOverDialog = Dialog(this);
  }

  Future handleStartUpLogic() async {
    await _pns.initialise();
  }

  void resize(Size size) {
    viewport = size;
    tileSize = viewport.width / 6;
    birdPosY = viewport.height - floorHeight - tileSize + (tileSize / 8);
  }

  void render(Canvas c) {
    skyBackground.render(c);
    c.save();
    c.translate(0, currentHeight);
    currentLevel.levelObstacles.forEach((obstacle) {
      if (isObstacleInRange(obstacle)) {
        obstacle.render(c);
      }
    });
    groundFloor.render(c);
    floorText.render(c);
    c.restore();

    birdPlayer.render(c);

    if (currentGameState == GameState.gameOver) {
      gameOverDialog.render(c);
    } else {
      scoreText.render(c);
    }

    if (currentGameState != GameState.gameOver) {
      // Make the bird flutter
      birdPlayer.startFlutter();
      isBirding = true;
      if (currentHeight.floor().toInt() <= 14999) {
        birdChangeValue = 1.0;
      } else if (currentHeight.floor().toInt() > 14999 &&
          currentHeight.floor().toInt() <= 29999) {
        birdChangeValue =
            birdChangeValue != 1.25 ? birdChangeValue + 0.25 : birdChangeValue;
      } else if (currentHeight.floor().toInt() > 29999 &&
          currentHeight.floor().toInt() <= 44999) {
        birdChangeValue =
            birdChangeValue != 1.5 ? birdChangeValue + 0.25 : birdChangeValue;
      } else if (currentHeight.floor().toInt() > 44999 &&
          currentHeight.floor().toInt() <= 59999) {
        birdChangeValue =
            birdChangeValue != 1.75 ? birdChangeValue + 0.25 : birdChangeValue;
      } else if (currentHeight.floor().toInt() > 59999 &&
          currentHeight.floor().toInt() <= 74999) {
        birdChangeValue =
            birdChangeValue != 2 ? birdChangeValue + 0.25 : birdChangeValue;
      } else if (currentHeight.floor().toInt() > 74999 &&
          currentHeight.floor().toInt() <= 89999) {
        birdChangeValue =
            birdChangeValue != 2.25 ? birdChangeValue + 0.25 : birdChangeValue;
      } else if (currentHeight.floor().toInt() > 89999 &&
          currentHeight.floor().toInt() <= 109999) {
        birdChangeValue =
            birdChangeValue != 2.5 ? birdChangeValue + 0.25 : birdChangeValue;
      } else if (currentHeight.floor().toInt() > 10999 &&
          currentHeight.floor().toInt() <= 129999) {
        birdChangeValue =
            birdChangeValue != 2.75 ? birdChangeValue + 0.25 : birdChangeValue;
      } else if (currentHeight.floor().toInt() > 129999 &&
          currentHeight.floor().toInt() <= 149999) {
        birdChangeValue =
            birdChangeValue != 3 ? birdChangeValue + 0.25 : birdChangeValue;
      } else if (currentHeight.floor().toInt() > 149999 &&
          currentHeight.floor().toInt() <= 170000) {
        birdChangeValue =
            birdChangeValue != 3.25 ? birdChangeValue + 0.25 : birdChangeValue;
      } else if (currentHeight.floor().toInt() > 170000 &&
          currentHeight.floor().toInt() <= 190000) {
        birdChangeValue =
            birdChangeValue != 3.5 ? birdChangeValue + 0.25 : birdChangeValue;
      } else if (currentHeight.floor().toInt() > 190000 &&
          currentHeight.floor().toInt() <= 210000) {
        birdChangeValue =
            birdChangeValue != 3.75 ? birdChangeValue + 0.25 : birdChangeValue;
      } else if (currentHeight.floor().toInt() > 210000) {
        birdChangeValue = 5;
      }
      birdValue = flutterIntensity * birdChangeValue;
    }
  }

  void update(double t) {
    if (currentGameState == GameState.playing) {
      currentLevel.levelObstacles.forEach((obstacle) {
        if (isObstacleInRange(obstacle)) {
          obstacle.update(t);
        }
      });
      skyBackground.update(t);
      birdPlayer.update(t);
      // Update scoreText
      scoreText.setText(currentHeight.floor().toString());
      scoreText.update(t);
      floorText.update(t);
      gameOverDialog.update(t);
      // Game tasks
      flutterHandler();
      checkCollision();
    }
  }

  void checkCollision() {
    currentLevel.levelObstacles.forEach((obstacle) {
      if (isObstacleInRange(obstacle)) {
        if (birdPlayer.toCollisionRect().overlaps(obstacle.toRect())) {
          obstacle.markHit();
          gameOver();
        }
      }
    });
  }

  void gameOver() {
    currentGameState = GameState.gameOver;
  }

  void restartGame() {
    birdPlayer.setRotation(0);
    currentHeight = 0;
    currentLevel.generateObstacles();
    currentGameState = GameState.playing;
  }

  bool isObstacleInRange(Obstacle obs) {
    if (-obs.y < viewport.height + currentHeight &&
        -obs.y > currentHeight - viewport.height) {
      return true;
    } else {
      return false;
    }
  }

  void flutterHandler() {
    checkCollision();
    if (isBirding) {
      //  birdValue = birdValue * 0.8;
      currentHeight += birdValue;
      birdPlayer.setRotation(-birdValue * birdPlayer.direction * 1.5);
      // Cut the jump below 1 unit
      if (birdValue < 1) isBirding = false;
    } else {
      // If max. fallspeed not yet reached
      if (birdValue < 15) {
        birdValue = birdValue * 1.2;
      }
      if (currentHeight > birdValue) {
        birdPlayer.setRotation(birdValue * birdPlayer.direction * 2);
        currentHeight -= birdValue;
        // stop jumping below floor
      } else if (currentHeight > 0) {
        currentHeight = 0;
        birdPlayer.setRotation(0);
      }
    }
  }

  void onTapDown(TapDownDetails d) {
    if (currentGameState != GameState.gameOver) {
      if (birdPlayer.characterSpritesIndex == 1) {
        birdPlayer.characterSpritesIndex = 0;
        birdPlayer.direction = 1;
      } else if (birdPlayer.characterSpritesIndex == 0) {
        birdPlayer.characterSpritesIndex = 1;
        birdPlayer.direction = -1;
      } //click to change direction
      isBirding = true;
      return;
    }
    if (gameOverDialog.playButton.contains(d.globalPosition)) {
      restartGame();
    }
  }

  void onTapUp(TapUpDetails d) {
    birdPlayer.endFlutter();
  }

}


