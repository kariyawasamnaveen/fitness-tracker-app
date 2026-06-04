class DateUtility {
  /// Calculates the number of full days passed since the [startDate].
  static int getDaysPassed(DateTime startDate) {
    final now = DateTime.now();
    // Use only date parts to avoid issues with time differences
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final today = DateTime(now.year, now.month, now.day);
    return today.difference(start).inDays;
  }

  /// Calculates push-ups count: Base 1 + (daysPassed / 4)
  static int calculatePushUps(int daysPassed) {
    return 1 + (daysPassed ~/ 4);
  }

  /// Calculates squats count: Base 1 + (daysPassed / 4)
  static int calculateSquats(int daysPassed) {
    return 1 + (daysPassed ~/ 4);
  }

  /// Calculates jogging rounds: Base 1 + (daysPassed / 30)
  static int calculateJoggingRounds(int daysPassed) {
    return 1 + (daysPassed ~/ 30);
  }

  /// Calculates sprints (6m): Base 1 + (daysPassed / 30)
  static int calculateSprints(int daysPassed) {
    return 1 + (daysPassed ~/ 30);
  }

  /// Jumping Jacks are fixed at 10
  static int getJumpingJacks() {
    return 10;
  }
}
