import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/widgets/change_temporary_password_fields.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/l10n/auth_flow_strings.dart';

final class ChangeTemporaryPasswordDialog extends StatefulWidget {
  const ChangeTemporaryPasswordDialog({required this.arabic, super.key});
  final bool arabic;

  static Future<String?> show(BuildContext context, {required bool arabic}) =>
      showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => ChangeTemporaryPasswordDialog(arabic: arabic),
      );

  @override
  State<ChangeTemporaryPasswordDialog> createState() =>
      _ChangeTemporaryPasswordDialogState();
}

final class _ChangeTemporaryPasswordDialogState
    extends State<ChangeTemporaryPasswordDialog> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  String? _dialogError;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final p1 = _passwordCtrl.text.trim();
    final p2 = _confirmCtrl.text.trim();
    final err = p1.length < 8
        ? AuthFlowStrings.passwordMinLength(widget.arabic)
        : p1 == '123456'
            ? AuthFlowStrings.passwordCannotBe123456(widget.arabic)
            : p1 != p2
                ? AuthFlowStrings.passwordsDoNotMatch(widget.arabic)
                : null;
    if (err != null) return setState(() => _dialogError = err);
    Navigator.pop(context, p1);
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title:
              Text(AuthFlowStrings.changeTemporaryPasswordTitle(widget.arabic)),
          content: SingleChildScrollView(
            child: ChangeTemporaryPasswordFields(
              arabic: widget.arabic,
              passwordCtrl: _passwordCtrl,
              confirmCtrl: _confirmCtrl,
              obscure: _obscure,
              onToggleObscure: () => setState(() => _obscure = !_obscure),
              errorMessage: _dialogError,
            ),
          ),
          actions: [
            FilledButton(
              onPressed: _submit,
              child: Text(AppStrings.save(widget.arabic)),
            ),
          ],
        ),
      );
}
