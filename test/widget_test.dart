import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:positive_attitude_creator/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PositiveAttitudeApp(),
      ),
    );
    // Verify splash screen renders
    expect(find.text('Positive Attitude'), findsOneWidget);
    expect(find.text('Creator'), findsOneWidget);
  });
}
