import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/local_account.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

/// Interactive login form with direct account selection, inline password visibility toggle,
/// validation messages, and responsive loading states.
final class AuthLoginForm extends StatefulWidget {
  const AuthLoginForm({
    required this.accounts,
    required this.selectedAccountId,
    required this.onAccountChanged,
    required this.onSignIn,
    required this.busy,
    required this.errorMessage,
    required this.arabic,
    super.key,
  });

  final List<LocalAccount> accounts;
  final String? selectedAccountId;
  final ValueChanged<String?> onAccountChanged;
  final Future<void> Function(String accountId, String password) onSignIn;
  final bool busy;
  final String? errorMessage;
  final bool arabic;

  @override
  State<AuthLoginForm> createState() => _AuthLoginFormState();
}

final class _AuthLoginFormState extends State<AuthLoginForm> {
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

    final accountId = widget.selectedAccountId;
    if (accountId == null || accountId.isEmpty) {
      setState(() {
        _localValidationError = widget.arabic
            ? 'يرجى اختيار الحساب أولاً'
            : 'Please select an account first';
      });
      return;
    }

    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _localValidationError = widget.arabic
            ? 'يرجى إدخال كلمة المرور'
            : 'Please enter your password';
      });
      return;
    }

    widget.onSignIn(accountId, password);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveError = _localValidationError ?? widget.errorMessage;

    return Padding(
      padding: const EdgeInsets.all(AppTokens.space24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.lock_outline, size: 54, color: AppTokens.primary),
          const SizedBox(height: AppTokens.space16),
          Text(
            AppStrings.login(widget.arabic),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTokens.space24),
          DropdownButtonFormField<String>(
            initialValue: widget.accounts.any((a) => a.id == widget.selectedAccountId)
                ? widget.selectedAccountId
                : (widget.accounts.firstOrNull?.id),
            decoration: InputDecoration(
              labelText: AppStrings.selectAccount(widget.arabic),
              prefixIcon: const Icon(Icons.person_outline),
              border: const OutlineInputBorder(),
            ),
            items: widget.accounts
                .map(
                  (account) => DropdownMenuItem(
                    value: account.id,
                    child: Text('${account.displayName} (${account.role.label(arabic: widget.arabic)})'),
                  ),
                )
                .toList(),
            onChanged: widget.busy ? null : widget.onAccountChanged,
          ),
          const SizedBox(height: AppTokens.space16),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            enabled: !widget.busy,
            decoration: InputDecoration(
              labelText: AppStrings.password(widget.arabic),
              prefixIcon: const Icon(Icons.key_outlined),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: _obscurePassword
                    ? AppStrings.showPassword(widget.arabic)
                    : AppStrings.hidePassword(widget.arabic),
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
                  const Icon(Icons.error_outline, color: AppTokens.statusUnknown, size: 20),
                  const SizedBox(width: AppTokens.space8),
                  Expanded(
                    child: Text(
                      effectiveError,
                      style: const TextStyle(color: AppTokens.statusUnknown, fontSize: 13),
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
              onPressed: widget.busy ? null : _handleSubmit,
              child: widget.busy
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: AppTokens.onPrimary, strokeWidth: 2.5),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.login),
                        const SizedBox(width: AppTokens.space8),
                        Text(AppStrings.login(widget.arabic), style: const TextStyle(fontSize: 18)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
