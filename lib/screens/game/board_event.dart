abstract class BoardEvent {}

class InitialEvent extends BoardEvent {}

class NewGameEvent extends BoardEvent {}

class WonGameEvent extends BoardEvent {}

class ActionPerformedEvent extends BoardEvent {
  int indexPressed;

  ActionPerformedEvent({
    required this.indexPressed,
  });
}

class PerformActionEvent extends BoardEvent {
  int indexPressed;

  PerformActionEvent({
    required this.indexPressed,
  });
}
