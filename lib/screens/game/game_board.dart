import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:flip_anime/screens/game/players.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/constants.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/flip_animation.dart';
import '../../widgets/game_end_widget.dart';
import '../../widgets/player_widget.dart';
import 'board_controller.dart';
import 'board_event.dart';
//Song: My Mind goes salalalala or Cupid, or both

class GameBoard extends StatefulWidget {
  final BoardController boardController;
  final List<Players> players;

  const GameBoard({
    super.key,
    required this.players,
    required this.boardController,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  final List<FlipController> _flipController =
      List.generate(boardItems.length, (i) => FlipController());

  ///On user's turn they have tap two elements to check whether they match.
  ///This list stores the index of the two elements pressed
  final List<int> _twoTapsIndex = [];

  final List<int> _alreadyFlippedItemsIndex = [];
  final List<String> _allBoardItems = List.from(boardItems)..shuffle();

  int _currentTurnIndex = 0;
  final List<int> _playerScoreList = [];
  final List<Color> _backgroundColor = List.from(playerBgColor);

  @override
  void initState() {
    super.initState();
    _setInitialScore();
  }

  @override
  void dispose() {
    _flipController.map((e) {
      e.dispose();
    }).toList();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _printLogs();
    _mayComputerPerformMove();
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: Container(
          height: double.infinity,
          color: _backgroundColor[_currentTurnIndex],
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 10.h,
          ),
          child: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    height: 20.h,
                    width: 20.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: _backgroundColor[_currentTurnIndex],
                    ),
                    alignment: Alignment.center,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35.w),
                    child: GridView.builder(
                      itemCount: _allBoardItems.length,
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.5,
                      ),
                      itemBuilder: (context, index) {
                        if (_flipController.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return GestureDetector(
                          onTap: () {
                            _onItemPressed(index);
                          },
                          child: FlipAnimation(
                            controller: _flipController[index],
                            firstChild: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40.r),
                                color: Colors.white,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40.r),
                                child: Image.asset('assets/images/card_bg.jpg'),
                              ),
                            ),
                            secondChild: Container(
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40.r),
                                color: Colors.white,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40.r),
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                        _allBoardItems[index],
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (_gameOver) ...[
                  Center(
                    child: GameEndWidget(
                      onPlayTap: _resetGame,
                      onMenuTap: null, //Todo: Remove this
                    ),
                  ),
                  Builder(builder: (context) {
                    var (align, transform) = _getWinnerAlignments();
                    return Align(
                      alignment: align,
                      child: Transform.rotate(
                        alignment: transform,
                        angle: -math.pi / 4,
                        child: Image.asset(
                          'assets/gifs/winner.gif',
                          height: 50.h,
                        ),
                      ),
                    );
                  }),
                ],
                for (int i = 0; i < widget.players.length; i++)
                  Align(
                    alignment: [
                      Alignment.topLeft,
                      Alignment.bottomRight,
                      Alignment.topRight,
                      Alignment.bottomLeft,
                    ][i],
                    child: PlayerWidget(
                      color: _backgroundColor[i],
                      score: _playerScoreList[i],
                    ),
                  ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onLongPress: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 25.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///Checks whether its computer turn, if yes then make computer move
  void _mayComputerPerformMove() {
    final player = _currentPlayer;
    if (player is Computer) {
      player.performMove(_performFlipAction);
    }
  }

  Players get _currentPlayer => widget.players[_currentTurnIndex];

  void _setInitialScore() {
    _playerScoreList.clear();
    _playerScoreList.addAll([0, 0, 0, 0]);
  }

  void _resetGame() async {
    _twoTapsIndex.clear();
    _flipController.map((e) => e.isFront = true).toList();
    _currentTurnIndex = 0;
    _setInitialScore();
    _allBoardItems.shuffle();
    _alreadyFlippedItemsIndex.clear();
    widget.boardController.value = NewGameEvent();
    for (var player in widget.players) {
      if (player is Computer) {
        player.clearTheMemory();
      }
    }
    setState(() {});
  }

  Future<bool> _onBackPressed() async {
    final value = await showDialog(
        context: context,
        builder: (context) {
          return const CustomDialog(
            heading: "Give Up",
            title:
                "Is it okay for you if your friends mocks you by saying that you are a guy who easily give up??",
            yes: "Yes",
            no: "No! I Never Give up.",
          );
        });
    if (value == true) {
      if (!mounted) return false;
      Navigator.pop(context);
    }
    return false;
  }

  void _onItemPressed(int index) async {
    if (_ignoreOnPress(index)) return;
    _performFlipAction(index);
  }

  Future<void> _performFlipAction(
    int index,
  ) async {
    _flipController[index].flip();
    log(_flipController[index].value.toString(), name: 'flipped');
    _twoTapsIndex.add(index);
    _alreadyFlippedItemsIndex.add(index);
    await _checkIsSecondAndIsAMatch();
    widget.boardController.value = ActionPerformedEvent(indexPressed: index);
  }

  bool _ignoreOnPress(int index) {
    if (_twoTapsIndex.length >= 2) return true;
    if (_currentPlayer is Computer) return true;
    if (_alreadyFlippedItemsIndex.contains(index)) return true;
    return false;
  }

  Future<void> _checkIsSecondAndIsAMatch() async {
    if (_itsUserFirstTurn) {
      _addToMemoryIfComputer();
      return;
    }
    if (_isCorrectMatch) {
      _playerMatchedCorrectly();
    } else {
      await _playerMatchedIncorrectly();
    }
    _nextUserTurn();
  }

  bool get _itsUserFirstTurn => _twoTapsIndex.length == 1;

  bool get _isCorrectMatch => _twoTapsIndex[0] == _twoTapsIndex[1];

  void _playerMatchedCorrectly() {
    _playerScoreList[_currentTurnIndex]++;
    if (!_gameOver) {
      _twoTapsIndex.clear();
    }
  }

  bool get _gameOver =>
      _allBoardItems.length == _alreadyFlippedItemsIndex.length;

  Future<void> _playerMatchedIncorrectly() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _addToMemoryIfComputer();
    _flipController[_twoTapsIndex[0]].flip();
    _flipController[_twoTapsIndex[1]].flip();
    _alreadyFlippedItemsIndex.remove(_twoTapsIndex[0]);
    _alreadyFlippedItemsIndex.remove(_twoTapsIndex[1]);
  }

  ///Must be called when a user had made its all 2 moves
  void _nextUserTurn() {
    if (_currentTurnIndex < widget.players.length - 1) {
      _currentTurnIndex++;
    } else {
      _currentTurnIndex = 0;
    }
    _twoTapsIndex.clear();
    setState(() {});
  }

  void _addToMemoryIfComputer() {
    int index = _twoTapsIndex.last;
    final player = _currentPlayer;
    if (player is Computer) {
      player.observerTheCard(index);
    }
  }

  (Alignment align, Alignment transform) _getWinnerAlignments() {
    var align = Alignment.center;
    var transform = Alignment.center;
    if (_playerScoreList[0] > _playerScoreList[1] &&
        _playerScoreList[0] > _playerScoreList[2] &&
        _playerScoreList[0] > _playerScoreList[3]) {
      align = Alignment.topLeft;
      transform = Alignment.bottomRight;
    } else if (_playerScoreList[1] > _playerScoreList[2] &&
        _playerScoreList[1] > _playerScoreList[3]) {
      align = Alignment.topLeft;
      align = Alignment.bottomRight;
    } else if (_playerScoreList[2] > _playerScoreList[3]) {
      align = Alignment.bottomRight;
      transform = Alignment.topLeft;
    } else {
      align = Alignment.bottomLeft;
      transform = Alignment.topRight;
    }
    return (align, transform);
  }

  void _printLogs() {
    log('Build Rebuild. Below are Players scores.');
    log(widget.players.length.toString(), name: 'Number of Players');
    for (int i = 0; i < widget.players.length; i++) {
      log(_playerScoreList[i].toString(), name: 'Player ${i + 1} Score');
    }
    log(
      "Player ${_currentTurnIndex + 1}'s Turn (${_currentPlayer.name} ${_currentPlayer.runtimeType})",
      name: "Current Player",
    );
    log(_backgroundColor.toString(), name: 'Background Color');
  }
}
