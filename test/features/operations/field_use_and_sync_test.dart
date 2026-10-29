import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/operation_sync_outcome.dart';
import 'package:radar_labor/features/operations/domain/search_match.dart';
import 'package:radar_labor/features/operations/presentation/widgets/operation_sync_helper.dart';
import 'package:radar_labor/features/operations/presentation/widgets/search_highlight_text.dart';
import 'package:radar_labor/features/operations/presentation/widgets/site_attendance_more_menu.dart';
import 'package:radar_labor/features/operations/presentation/widgets/unsaved_changes_guard.dart';

void main() {
  group('SearchMatch & SearchHighlightText (Phase 5)', () {
    test('splits text correctly into matched and unmatched segments', () {
      final segments = SearchMatch.split('Ahmed Ali', 'Ali');
      expect(segments.length, 2);
      expect(segments[0].text, 'Ahmed ');
      expect(segments[0].matched, isFalse);
      expect(segments[1].text, 'Ali');
      expect(segments[1].matched, isTrue);

      final multiSegments = SearchMatch.split('Ahmed Ali', 'al');
      expect(multiSegments.length, 3);
      expect(multiSegments[0].text, 'Ahmed ');
      expect(multiSegments[1].text, 'Al');
      expect(multiSegments[1].matched, isTrue);
      expect(multiSegments[2].text, 'i');
      expect(multiSegments[2].matched, isFalse);

      final emptySegments = SearchMatch.split('Worker 123', '');
      expect(emptySegments.length, 1);
      expect(emptySegments[0].matched, isFalse);

      final noMatch = SearchMatch.split('Worker 123', 'xyz');
      expect(noMatch.length, 1);
      expect(noMatch[0].matched, isFalse);
    });

    testWidgets('SearchHighlightText renders highlighted text spans', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SearchHighlightText(text: 'Worker 42', query: '42'),
          ),
        ),
      );
      final widgetFinder = find.byType(SearchHighlightText);
      expect(widgetFinder, findsOneWidget);
      final textWidget = tester.widget<Text>(
        find.descendant(of: widgetFinder, matching: find.byType(Text)),
      );
      final span = textWidget.textSpan as TextSpan;
      expect(span.children, isNotNull);
      expect(span.children!.length, 2);
      expect(span.children![0].toPlainText(), 'Worker ');
      expect(span.children![1].toPlainText(), '42');
      expect(
        span.children![1].style?.backgroundColor,
        AppTokens.searchHighlight,
      );
    });
  });

  group('OperationSyncOutcome & operationSyncSnackBar (Phase 1 & Phase 5)', () {
    test('classify maps outcome states faithfully', () {
      expect(
        OperationSyncOutcome.classify(
          offline: true,
          sessionRevoked: false,
          pendingRemaining: 5,
        ),
        OperationSyncOutcome.offline,
      );
      expect(
        OperationSyncOutcome.classify(
          offline: false,
          sessionRevoked: true,
          pendingRemaining: 0,
        ),
        OperationSyncOutcome.sessionRevoked,
      );
      expect(
        OperationSyncOutcome.classify(
          offline: false,
          sessionRevoked: false,
          pendingRemaining: 3,
        ),
        OperationSyncOutcome.pending,
      );
      expect(
        OperationSyncOutcome.classify(
          offline: false,
          sessionRevoked: false,
          pendingRemaining: 0,
        ),
        OperationSyncOutcome.synced,
      );

      expect(OperationSyncOutcome.synced.isConfirmedSuccess, isTrue);
      expect(OperationSyncOutcome.pending.isConfirmedSuccess, isFalse);
      expect(OperationSyncOutcome.offline.isConfirmedSuccess, isFalse);
      expect(OperationSyncOutcome.failed.isConfirmedSuccess, isFalse);
    });

    testWidgets(
      'showOperationSyncSnackBar shows green only for confirmed sync',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showOperationSyncSnackBar(
                    context,
                    OperationSyncOutcome.synced,
                    arabic: false,
                  ),
                  child: const Text('Show'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Show'));
        await tester.pump();

        final snackBarFinder = find.byType(SnackBar);
        expect(snackBarFinder, findsOneWidget);
        final snackBar = tester.widget<SnackBar>(snackBarFinder);
        expect(snackBar.backgroundColor, AppTokens.statusOnSite);
        expect(
          find.text(OperationsStrings.syncSuccessMessage(false)),
          findsOneWidget,
        );
      },
    );

    testWidgets('showOperationSyncSnackBar shows amber for offline fallback', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showOperationSyncSnackBar(
                  context,
                  OperationSyncOutcome.offline,
                  arabic: false,
                ),
                child: const Text('Show Offline'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Show Offline'));
      await tester.pump();

      final snackBarFinder = find.byType(SnackBar);
      expect(snackBarFinder, findsOneWidget);
      final snackBar = tester.widget<SnackBar>(snackBarFinder);
      expect(snackBar.backgroundColor, AppTokens.statusHousingOnly);
      expect(
        find.text(OperationsStrings.syncOfflineFallbackMessage(false)),
        findsOneWidget,
      );
    });
  });

  group('UnsavedChangesGuard (Phase 5)', () {
    testWidgets('allows direct exit when local draft is already persisted', (
      tester,
    ) async {
      var popped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (context) => UnsavedChangesGuard(
                hasUnsavedChanges: false,
                persistDraft: () async => true,
                arabic: false,
                child: Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      popped = true;
                    },
                    child: const Text('Exit'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Exit'));
      await tester.pumpAndSettle();
      expect(popped, isTrue);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets(
      'flushes pending draft on back; if successful, leaves without warning dialog',
      (tester) async {
        var flushCalled = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (childContext) => UnsavedChangesGuard(
                        hasUnsavedChanges: true,
                        persistDraft: () async {
                          flushCalled = true;
                          return true;
                        },
                        arabic: false,
                        child: const Scaffold(body: BackButton()),
                      ),
                    ),
                  ),
                  child: const Text('Push'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Push'));
        await tester.pumpAndSettle();
        expect(find.byType(BackButton), findsOneWidget);

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        expect(flushCalled, isTrue);
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.text('Push'), findsOneWidget);
      },
    );

    testWidgets(
      'shows confirmation alert only when draft flush fails; staying cancels pop',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (childContext) => UnsavedChangesGuard(
                        hasUnsavedChanges: true,
                        persistDraft: () async => false, // fails
                        arabic: false,
                        child: const Scaffold(body: BackButton()),
                      ),
                    ),
                  ),
                  child: const Text('Push'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Push'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(
          find.text(OperationsStrings.unsavedChangesTitle(false)),
          findsOneWidget,
        );

        // Tap Stay
        await tester.tap(find.text(OperationsStrings.stayAction(false)));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(find.byType(BackButton), findsOneWidget);
      },
    );
  });

  group('SiteAttendanceMoreMenu (Phase 4)', () {
    testWidgets('renders overflow menu with secondary actions', (tester) async {
      SiteAttendanceMenuAction? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SiteAttendanceMoreMenu(
              arabic: false,
              canEditTeam: true,
              onSelected: (action) => selected = action,
            ),
          ),
        ),
      );

      expect(find.byKey(const ValueKey('site_more_menu')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('site_more_menu')));
      await tester.pumpAndSettle();

      expect(
        find.text(OperationsStrings.addFromAnotherTeam(false)),
        findsOneWidget,
      );
      expect(find.text(OperationsStrings.clearAll(false)), findsOneWidget);
      expect(find.text(OperationsStrings.editTeam(false)), findsOneWidget);

      await tester.tap(find.text(OperationsStrings.clearAll(false)));
      await tester.pumpAndSettle();
      expect(selected, SiteAttendanceMenuAction.clearAll);
    });
  });
}
