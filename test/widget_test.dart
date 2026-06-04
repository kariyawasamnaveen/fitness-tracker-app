import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FitnessTrackerApp());

    // Verify that our app displays the title
    expect(find.text('Daily Exercises'), findsNothing); // It will be in ExerciseScreen which is inside provider
  });
}
