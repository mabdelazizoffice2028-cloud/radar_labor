import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/widgets/login_submit_button.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/l10n/auth_flow_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class LoginPasswordRow extends StatefulWidget {
  const LoginPasswordRow({
    required this.controller,
    required this.busy,
    required this.arabic,
    required this.onSubmit,
    super.key,
  });

  static const double sideBySideMinWidth = 360;

  final TextEditingController controller;
  final bool busy;
  final bool arabic;
  final VoidCallback onSubmit;

  @override
  State<LoginPasswordRow> createState() => _LoginPasswordRowState();
}

final class _LoginPasswordRowState extends State<LoginPasswordRow> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final ar = widget.arabic;
    final field = TextField(
      key: const ValueKey('password_field'),
      controller: widget.controller,
      obscureText: _obscure,
      enabled: !widget.busy,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: AuthFlowStrings.enterPasswordLabel(ar),
        prefixIcon: const Icon(Icons.key_outlined),
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          tooltip:
              _obscure ? AppStrings.showPassword(ar) : AppStrings.hidePassword(ar),
          icon: Icon(
            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      onSubmitted: (_) => widget.onSubmit(),
    );
    final btn = LoginSubmitButton(
      busy: widget.busy,
      arabic: ar,
      onSubmit: widget.onSubmit,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= LoginPasswordRow.sideBySideMinWidth) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: field),
              const SizedBox(width: AppTokens.space12),
              btn,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [field, const SizedBox(height: AppTokens.space12), btn],
        );
      },
    );
  }
}
