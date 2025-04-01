sealed class StrategyResult<T> {
  T command;

  StrategyResult(this.command);
}

class TimedCommand<T> extends StrategyResult<T> {
  Duration duration;

  TimedCommand(super.command, this.duration);
}

class Command<T> extends StrategyResult<T> {
  Command(super.command);
}
