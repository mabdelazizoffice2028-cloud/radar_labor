import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/login/login_flow_notifier.dart';
import 'package:radar_labor/app/login/role_picker.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/l10n/auth_flow_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

/// Role -> Name -> Password login form (PRD §23.2, BC-5).
final class AuthLoginForm extends StatefulWidget {
  const AuthLoginForm({
    required this.flowState,
    required this.onRoleSelected,
    required this.onClearRole,
    required this.onAccountChanged,
    required this.onSignIn,
    required this.busy,
    required this.errorMessage,
    required this.arabic,
    super.key,
  });

  final LoginFlowState flowState;
  final ValueChanged<AuthRole> onRoleSelected;
  final VoidCallback onClearRole;
  final ValueChanged<String?> onAccountChanged;
  final Future<void> Function(AuthRole role, String accountId, String password)
  onSignIn;
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
    final role = widget.flowState.selectedRole;
    if (role == null) {
      setState(
        () => _localValidationError = AuthFlowStrings.selectRoleFirstError(
          widget.arabic,
        ),
      );
      return;
    }
    final accountId = widget.flowState.selectedAccountId;
    if (accountId == null || accountId.isEmpty) {
      setState(
        () => _localValidationError = AuthFlowStrings.selectNameFirstError(
          widget.arabic,
        ),
      );
      return;
    }
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(
        () => _localValidationError = AuthFlowStrings.enterPasswordError(
          widget.arabic,
        ),
      );
      return;
    }
    widget.onSignIn(role, accountId, password);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveError = _localValidationError ?? widget.errorMessage;
    final state = widget.flowState;
    final selectedRole = state.selectedRole;
    final roleAccounts = state.accountsForRole;

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
          if (selectedRole == null)
            RolePicker(
              arabic: widget.arabic,
              onRoleSelected: (role) {
                setState(() => _localValidationError = null);
                widget.onRoleSelected(role);
              },
            )
          else ...[
            _SelectedRoleBanner(
              role: selectedRole,
              arabic: widget.arabic,
              onChangeRole: widget.busy
                  ? null
                  : () {
                      _passwordController.clear();
                      setState(() => _localValidationError = null);
                      widget.onClearRole();
                    },
            ),
            const SizedBox(height: AppTokens.space16),
            if (roleAccounts.isEmpty)
              _ErrorBanner(
                message: AuthFlowStrings.noAccountsForRole(widget.arabic),
              )
            else ...[
              if (state.showNameDropdown) ...[
                DropdownButtonFormField<String>(
                  key: ValueKey('account_dropdown_${selectedRole.name}'),
                  initialValue: state.selectedAccountId,
                  decoration: InputDecoration(
                    labelText: AuthFlowStrings.chooseNameLabel(widget.arabic),
                    prefixIcon: const Icon(Icons.person_outline),
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    for (final account in roleAccounts)
                      DropdownMenuItem(
                        value: account.id,
                        child: Text(account.displayName),
                      ),
                  ],
                  onChanged: widget.busy ? null : widget.onAccountChanged,
                ),
                const SizedBox(height: AppTokens.space16),
              ] else if (state.selectedAccount != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppTokens.space12),
                  decoration: BoxDecoration(
                    color: AppTokens.primarySoft,
                    borderRadius: BorderRadius.circular(AppTokens.radius12),
                  ),
                  child: Text(
                    AuthFlowStrings.singleAccountNotice(
                      widget.arabic,
                      state.selectedAccount!.displayName,
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: AppTokens.space16),
              ],
              TextField(
                key: const ValueKey('password_field'),
                controller: _passwordController,
                obscureText: _obscurePassword,
                enabled: !widget.busy,
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
                _ErrorBanner(message: effectiveError),
              ],
              const SizedBox(height: AppTokens.space24),
              SizedBox(
                height: AppTokens.minTouchTarget,
                child: FilledButton(
                  key: const ValueKey('login_submit_button'),
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
            ],
          ],
        ],
      ),
    );
  }
}

final class _SelectedRoleBanner extends StatelessWidget {
  const _SelectedRoleBanner({
    required this.role,
    required this.arabic,
    required this.onChangeRole,
  });

  final AuthRole role;
  final bool arabic;
  final VoidCallback? onChangeRole;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppTokens.space12,
      vertical: AppTokens.space8,
    ),
    decoration: BoxDecoration(
      color: AppTokens.surface,
      borderRadius: BorderRadius.circular(AppTokens.radius12),
      border: Border.all(color: AppTokens.outline),
    ),
    child: Row(
      children: [
        const Icon(Icons.verified_user_outlined, color: AppTokens.primary),
        const SizedBox(width: AppTokens.space8),
        Expanded(
          child: Text(
            role.label(arabic: arabic),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton.icon(
          key: const ValueKey('change_role_button'),
          onPressed: onChangeRole,
          icon: const Icon(Icons.swap_horiz, size: 18),
          label: Text(AuthFlowStrings.changeRole(arabic)),
        ),
      ],
    ),
  );
}

final class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
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
            message,
            style: const TextStyle(
              color: AppTokens.statusUnknown,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );
}
