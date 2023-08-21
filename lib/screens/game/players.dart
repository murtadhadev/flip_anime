import 'dart:async';
import 'dart:math';

import 'board_controller.dart';

enum GameplayType {
  offline,
  online,
}

enum ComputerExpertise {
  noob,
  intermediate,
  pro,
}

abstract class Players {
  String name;
  GameplayType gameplayType;

  Players({
    required this.name,
    required this.gameplayType,
  });
}



///Computer have its memory, which observes all the moves made in the game.
///The memory keeps expanding as the game continues. With more memories,
///computer can easily figure out which Card have which item.
///
///Computer makes moves from its memory, if its memory have no match then
///it keeps on expanding its memory by picking new cards to explore the unknown.
///
///Computer expertise is either noob, intermediate, or pro.
///
///More expertise means more memory and less mistakes.
//Todo: Proper encapsulation
//Todo: Proper testing of addictiveness as per expertise of Computer
class Computer extends Players {
  final Random _random = Random();
  //Todo: How to get below variables
  ComputerExpertise computerExpertise;
  final BoardController boardController;
  final List<int> availableIndex;
  final List<String> boardImages;

  //Todo: Make sure same index are not redundant

  /// The indexes of [boardImages] which the Computer remembers
  final List<int> _computerMemory = [];

  void observerTheCard(int index) {
    _computerMemory.add(index);
  }

  void clearTheMemory() {
    _computerMemory.clear();
  }

  void performMove(Future<void> Function(int index) performAction) async {
    _mayForgotTwoMemories();
    //Performing Move One
    final moveOneIndex = _computerGetsEmotional?_randomMove:_bestFirstMove();
    await performAction(
        moveOneIndex); //This needs to await, then only perform next move
    //Performing Move Two
    performAction(_computerGetsEmotional?_randomMove:_bestSecondMove(moveOneIndex));
  }

  void _mayForgotTwoMemories() {
    final (requiredLastValue, probablitiy)=_expertiseVsForgetting();
    if (_computerMemory.length > requiredLastValue + 1) {
      bool shouldForgot = _random.nextDouble() < probablitiy;
      if (shouldForgot) {
        for (int i = 0; i < 2; i++) {
          int indexToForgot =
          _random.nextInt(_computerMemory.length - requiredLastValue);
          _computerMemory.removeAt(indexToForgot);
        }
      }
    }
  }

  (int requiredLastValue, double probability) _expertiseVsForgetting() {
    return switch (computerExpertise) {
      ComputerExpertise.noob => (2, 0.6),
      ComputerExpertise.intermediate => (3, 0.3),
      ComputerExpertise.pro => (4, 0.15),
    };
  }

  int _bestSecondMove(int previousIndex) {
    var sendMoveIndex = -1;
    for (int i = 0; i < _computerMemory.length - 1; i++) {
      //Todo: Not the last verify. Why? Does this work?
      if (boardImages[_computerMemory[i]] == boardImages[previousIndex]) {
        if (availableIndex.contains(_computerMemory[i])) {
          sendMoveIndex = i;
          break;
        } else {
          Future.delayed(Duration.zero, () {
            //Todo: Does this logic work, if yes then you learned today something new
            availableIndex.removeAt(i);
          });
        }
      }
    }
    if (sendMoveIndex == -1) {
      sendMoveIndex = _bestFirstMove();
    }
    return sendMoveIndex;
  }

  int _bestFirstMove() {
    var answer = -1;
    //Way 1: Find whether both answer for specific card is saved in memory.
    // On no both element found go to Way 2
    final redundantMoveFromMemory = _findIndexFromRedundancy();
    if (redundantMoveFromMemory != null) return redundantMoveFromMemory;
    //Way 2: Find a card index which is not saved in memory, to explore new unknown and to expand computer memory
    //On all availableIndex already saved in memory, go to Way 3
    for (int i = 0; i < availableIndex.length; i++) {
      if (_computerMemory
          .indexWhere((element) => element == availableIndex[i]) ==
          -1) {
        answer = availableIndex[i];
        break;
      }
    }
    //Way 3: Randomly pick any available index
    if (answer == -1) {
      answer = _randomMove;
    }
    return answer;
  }

  int get _randomMove => availableIndex[_random.nextInt(availableIndex.length)];

  bool get _computerGetsEmotional {
    final probability= switch(computerExpertise){
      ComputerExpertise.noob => 1 / 10,
      ComputerExpertise.intermediate => 1 / 15,
      ComputerExpertise.pro => 1 / 20,
    };
    return _random.nextDouble()<probability;
  }

  int? _findIndexFromRedundancy() {
    List<int> uniqueElements = [];
    for (var memoryItem in _computerMemory) {
      if (uniqueElements.indexWhere((uniqueItem) => uniqueItem == memoryItem) !=
          -1) {
        return memoryItem;
      } else {
        uniqueElements.add(memoryItem);
      }
    }
    return null;
  }

  Computer({
    required super.name,
    required super.gameplayType,
    required this.computerExpertise,
    required this.availableIndex,
    required this.boardController,
    required this.boardImages,
  });
}

class RealPerson extends Players {
  RealPerson({
    required super.name,
    required super.gameplayType,
  });
}
