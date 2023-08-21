import 'package:flutter/material.dart';

import 'board_event.dart';

class BoardController extends ValueNotifier<BoardEvent> {
  BoardController() : super(InitialEvent());
}
