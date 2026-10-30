import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/l10n/auth_flow_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

/// Simplified PIN / Password entry screen for remembered users (PRD §23.2).
final class PinLoginForm extends StatefulWidget {
  const PinLoginForm({
    required this.account,
    required this.onSignIn,
    required this.onSwitchAccount,
    required this.busy,
    required this.errorMessage,
    required this.arabic,
    super.key,
  });

  final LocalAccount account;
  final Future<void> Function(String password) onSignIn;
  final VoidCallback onSwitchAccount;
  final bool busy;
  final String? errorMessage;
  final bool arabic;

  @override
  State<PinLoginForm> createState() => _PinLoginFormState();
}

final class _PinLoginFormState extends State<PinLoginForm> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _localValidationError;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    setState(() => _localValidationError = null);
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(
        () => _localValidationError = AuthFlowStrings.enterPasswordError(
          widget.arabic,
        ),
      );
      return;
    }
    widget.onSignIn(password);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveError = _localValidationError ?? widget.errorMessage;
    final account = widget.account;

    return Padding(
      padding: const EdgeInsets.all(AppTokens.space24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppTokens.primarySoft,
            child: const Icon(
              Icons.lock_person_outlined,
              size: 40,
              color: AppTokens.primary,
            ),
          ),
          const SizedBox(height: AppTokens.space16),
          Text(
            AuthFlowStrings.welcomeBack(widget.arabic),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppTokens.textSecondary),
          ),
          const SizedBox(height: AppTokens.space4),
          Text(
            account.displayName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTokens.textPrimary,
            ),
          ),
          const SizedBox(height: AppTokens.space8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.space12,
                vertical: AppTokens.space4,
              ),
              decoration: BoxDecoration(
                color: AppTokens.primarySoft,
                borderRadius: BorderRadius.circular(AppTokens.radiusChip),
              ),
              child: Text(
                account.role.label(arabic: widget.arabic),
                style: const TextStyle(
                  color: AppTokens.primaryDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTokens.space24),
          TextField(
            key: const ValueKey('remembered_password_field'),
            controller: _passwordController,
            obscureText: _obscurePassword,
            enabled: !widget.busy,
            autofocus: true,
            decoration: InputDecoration(
              labelText: AuthFlowStrings.enterPasswordLabel(widget.arabic),
              prefixIcon: const Icon(Icons.key_outlined),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: _obscurePassword
                    ? AppStrings.showPassword(widget.arabic)
                    : AppStrings.hidePassword(widget.arabic),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            onSubmitted: (_) => _handleSubmit(),
          ),
          if (effectiveError != null) ...[
            const SizedBox(height: AppTokens.space12),
            Container(
              padding: const EdgeInsets.all(AppTokens.space8),
              decoration: BoxDecoration(
                color: AppTokens.statusUnknownSoft,
                borderRadius: BorderRadius.circular(AppTokens.radius12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppTokens.statusUnknown,
                    size: 20,
                  ),
                  const SizedBox(width: AppTokens.space8),
                  Expanded(
                    child: Text(
                      effectiveError,
                      style: const TextStyle(
                        color: AppTokens.statusUnknown,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppTokens.space24),
          SizedBox(
            height: AppTokens.minTouchTarget,
            child: FilledButton(
              key: const ValueKey('remembered_login_button'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: widget.busy ? null : _handleSubmit,
              child: widget.busy
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppTokens.onPrimary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      AppStrings.login(widget.arabic),
                      style: const TextStyle(fontSize: 18),
                    ),
            ),
          ),
          const SizedBox(height: AppTokens.space12),
          TextButton.icon(
            key: const ValueKey('switch_account_button'),
            onPressed: widget.busy ? null : widget.onSwitchAccount,
            icon: const Icon(Icons.swap_horiz, size: 20),
            label: Text(AuthFlowStrings.switchAccount(widget.arabic)),
          ),
        ],
      ),
    );
  }
}
