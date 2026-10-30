import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/ui/components/app_empty_state.dart';

void main() {
  testWidgets('AppEmptyState renders icon and message without button',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppEmptyState(
            icon: Icons.people_outline,
            message: 'No workers found',
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.people_outline), findsOneWidget);
    expect(find.text('No workers found'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('AppEmptyState renders button and invokes callback when tapped',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppEmptyState(
            icon: Icons.history_outlined,
            message: 'No history yet',
            buttonText: 'Add New',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.history_outlined), findsOneWidget);
    expect(find.text('No history yet'), findsOneWidget);
    expect(find.text('Add New'), findsOneWidget);

    await tester.tap(find.text('Add New'));
    expect(tapped, isTrue);
  });
}
