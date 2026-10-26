import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';

/// Dialog allowing a signed-in user to input their current and replacement password.
final class UserPasswordChangeDialog extends StatefulWidget {
  const UserPasswordChangeDialog({required this.arabic, super.key});

  final bool arabic;

  @override
  State<UserPasswordChangeDialog> createState() =>
      _UserPasswordChangeDialogState();
}

final class _UserPasswordChangeDialogState
    extends State<UserPasswordChangeDialog> {
  final _current = TextEditingController();
  final _replacement = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _replacement.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ar = widget.arabic;
    return AlertDialog(
      title: Text(AppStrings.changePassword(ar)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _current,
            obscureText: true,
            decoration: InputDecoration(
              labelText: AppStrings.currentPassword(ar),
            ),
          ),
          TextField(
            controller: _replacement,
            obscureText: true,
            decoration: InputDecoration(labelText: AppStrings.newPassword(ar)),
          ),
          TextField(
            controller: _confirmation,
            obscureText: true,
            decoration: InputDecoration(
              labelText: AppStrings.confirmPassword(ar),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppStrings.cancel(ar)),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, (
            _current.text,
            _replacement.text,
            _confirmation.text,
          )),
          child: Text(AppStrings.save(ar)),
        ),
      ],
    );
  }
}
