import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/widgets/pin_login_header.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/l10n/auth_flow_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

/// Simplified PIN / Password entry screen for remembered users (PRD §23.2).
final class PinLoginForm extends StatefulWidget {
  const PinLoginForm({
    required this.account, required this.onSignIn, required this.onSwitchAccount,
    required this.busy, required this.errorMessage, required this.arabic, super.key,
  });

  final LocalAccount account;
  final Future<void> Function(String password) onSignIn;
  final VoidCallback onSwitchAccount;
  final bool busy, arabic;
  final String? errorMessage;

  @override
  State<PinLoginForm> createState() => _PinLoginFormState();
}

final class _PinLoginFormState extends State<PinLoginForm> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _localValidationError;

  @override
  void dispose() { _passwordController.dispose(); super.dispose(); }

  void _handleSubmit() {
    setState(() => _localValidationError = null);
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() => _localValidationError = AuthFlowStrings.enterPasswordError(widget.arabic));
      return;
    }
    widget.onSignIn(password);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveError = _localValidationError ?? widget.errorMessage;
    final ar = widget.arabic;
    return Padding(
      padding: const EdgeInsets.all(AppTokens.space24),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        PinLoginHeader(account: widget.account, arabic: ar),
        const SizedBox(height: AppTokens.space24),
        TextField(
          key: const ValueKey('remembered_password_field'),
          controller: _passwordController, obscureText: _obscurePassword, enabled: !widget.busy, autofocus: true,
          decoration: InputDecoration(
            labelText: AuthFlowStrings.enterPasswordLabel(ar),
            prefixIcon: const Icon(Icons.key_outlined), border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              tooltip: _obscurePassword ? AppStrings.showPassword(ar) : AppStrings.hidePassword(ar),
              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          onSubmitted: (_) => _handleSubmit(),
        ),
        if (effectiveError != null) ...[
          const SizedBox(height: AppTokens.space12),
          Container(
            padding: const EdgeInsets.all(AppTokens.space8),
            decoration: BoxDecoration(color: AppTokens.statusUnknownSoft, borderRadius: BorderRadius.circular(AppTokens.radius12)),
            child: Row(children: [
              const Icon(Icons.error_outline, color: AppTokens.statusUnknown, size: 20),
              const SizedBox(width: AppTokens.space8),
              Expanded(child: Text(effectiveError, style: const TextStyle(color: AppTokens.statusUnknown, fontSize: 13))),
            ]),
          ),
        ],
        const SizedBox(height: AppTokens.space24),
        SizedBox(
          height: AppTokens.minTouchTarget,
          child: FilledButton(
            key: const ValueKey('remembered_login_button'), onPressed: widget.busy ? null : _handleSubmit,
            child: widget.busy
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppTokens.onPrimary, strokeWidth: 2.5))
                : Text(AppStrings.login(ar), style: const TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(height: AppTokens.space12),
        TextButton.icon(
          key: const ValueKey('switch_account_button'), onPressed: widget.busy ? null : widget.onSwitchAccount,
          icon: const Icon(Icons.swap_horiz, size: 20), label: Text(AuthFlowStrings.switchAccount(ar)),
        ),
      ]),
    );
  }
}
