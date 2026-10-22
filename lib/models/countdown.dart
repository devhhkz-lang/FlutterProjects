sealed class Countdown {
  const Countdown();
}

class Upcoming extends Countdown {
  const Upcoming(this.left);

  final Duration left;
}

class Started extends Countdown {
  const Started(this.ago);

  final Duration ago;
}

class Ended extends Countdown {
  const Ended();
}
