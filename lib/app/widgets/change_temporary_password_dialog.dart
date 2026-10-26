import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

/// Modal dialog prompting the user to update their initial temporary password on first sign-in.
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
    if (p1.length < 8) {
      setState(
        () => _dialogError = widget.arabic
            ? 'كلمة المرور يجب ألا تقل عن 8 أحرف'
            : 'Must be at least 8 characters',
      );
      return;
    }
    if (p1 == '123456') {
      setState(
        () => _dialogError = widget.arabic
            ? 'لا يمكن استخدام 123456'
            : 'Cannot use 123456',
      );
      return;
    }
    if (p1 != p2) {
      setState(
        () => _dialogError = widget.arabic
            ? 'كلمتا المرور غير متطابقتين'
            : 'Passwords do not match',
      );
      return;
    }
    Navigator.pop(context, p1);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.arabic ? 'تغيير كلمة المرور المؤقتة' : 'Change temporary password',
    ),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.arabic
                ? 'يجب تعيين كلمة مرور جديدة لا تقل عن 8 أحرف ولا تساوي 123456.'
                : 'You must set a new password of at least 8 characters and not 123456.',
            style: const TextStyle(
              fontSize: 13,
              color: AppTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: AppStrings.newPassword(widget.arabic),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: AppStrings.confirmPassword(widget.arabic),
            ),
          ),
          if (_dialogError != null) ...[
            const SizedBox(height: 12),
            Text(
              _dialogError!,
              style: const TextStyle(
                color: AppTokens.statusUnknown,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    ),
    actions: [
      FilledButton(
        onPressed: _submit,
        child: Text(AppStrings.save(widget.arabic)),
      ),
    ],
  );
}
