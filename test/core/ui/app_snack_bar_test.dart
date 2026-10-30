import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/ui/app_snack_bar.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

void main() {
  testWidgets('AppSnackBar clears previous and uses floating behavior',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Column(
              children: [
                ElevatedButton(
                  onPressed: () => AppSnackBar.show(context, message: 'First'),
                  child: const Text('Show 1'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      AppSnackBar.show(context, message: 'Second'),
                  child: const Text('Show 2'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show 1'));
    await tester.pumpAndSettle();
    expect(find.text('First'), findsOneWidget);

    await tester.tap(find.text('Show 2'));
    await tester.pumpAndSettle();
    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsOneWidget);

    final bar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(bar.behavior, equals(SnackBarBehavior.floating));
    expect(bar.duration, equals(const Duration(seconds: 3)));

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Second'), findsNothing);
  });

  testWidgets('AppSnackBar is immediately dismissible by horizontal swipe',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () =>
                  AppSnackBar.show(context, message: 'Dismissible Notice'),
              child: const Text('Trigger'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Trigger'));
    await tester.pumpAndSettle();
    expect(find.text('Dismissible Notice'), findsOneWidget);

    // Swipe horizontally to dismiss
    await tester.drag(find.text('Dismissible Notice'), const Offset(500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Dismissible Notice'), findsNothing);
  });

  testWidgets('AppSnackBar semantic methods use correct colors and icons',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Column(
              children: [
                ElevatedButton(
                  onPressed: () =>
                      AppSnackBar.showSuccess(context, message: 'Success msg'),
                  child: const Text('Success'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      AppSnackBar.showError(context, message: 'Error msg'),
                  child: const Text('Error'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      AppSnackBar.showWarning(context, message: 'Warning msg'),
                  child: const Text('Warning'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Success'));
    await tester.pumpAndSettle();
    var bar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(bar.backgroundColor, equals(AppTokens.statusOnSite));
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

    await tester.tap(find.text('Error'));
    await tester.pumpAndSettle();
    bar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(bar.backgroundColor, equals(AppTokens.statusUnknown));
    expect(find.byIcon(Icons.error_outline), findsOneWidget);

    await tester.tap(find.text('Warning'));
    await tester.pumpAndSettle();
    bar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(bar.backgroundColor, equals(AppTokens.statusHousingOnly));
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });
}
