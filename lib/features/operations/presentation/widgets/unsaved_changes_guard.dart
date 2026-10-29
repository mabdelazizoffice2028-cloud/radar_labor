import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';

/// Warns before leaving a screen only when edits are not safely stored.
///
/// A draft persisted on the device is not lost data, so leaving first tries to
/// persist pending edits and only asks for confirmation when that fails.
final class UnsavedChangesGuard extends StatelessWidget {
  const UnsavedChangesGuard({
    required this.hasUnsavedChanges,
    required this.persistDraft,
    required this.arabic,
    required this.child,
    super.key,
  });

  final bool hasUnsavedChanges;

  /// Persists pending edits; returns false when they could not be stored.
  final Future<bool> Function() persistDraft;
  final bool arabic;
  final Widget child;

  Future<void> _onPopBlocked(BuildContext context) async {
    final navigator = Navigator.of(context);
    if (await persistDraft()) {
      if (context.mounted) navigator.pop();
      return;
    }
    if (!context.mounted) return;
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(OperationsStrings.unsavedChangesTitle(arabic)),
        content: Text(OperationsStrings.unsavedChangesBody(arabic)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(OperationsStrings.stayAction(arabic)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(OperationsStrings.leaveAction(arabic)),
          ),
        ],
      ),
    );
    if (leave == true && context.mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !hasUnsavedChanges,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _onPopBlocked(context);
    },
    child: child,
  );
}
