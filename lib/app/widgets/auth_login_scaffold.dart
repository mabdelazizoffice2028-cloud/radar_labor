import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/widgets/auth_language_button.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class AuthLoginScaffold extends StatelessWidget {
  const AuthLoginScaffold({
    required this.arabic,
    required this.child,
    super.key,
  });

  final bool arabic;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Scaffold(
      backgroundColor: AppTokens.background,
      appBar: AppBar(
        title: Text(AppStrings.appTitle(arabic)),
        centerTitle: true,
        actions: const [AuthLanguageButton()],
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppTokens.space16,
              AppTokens.space16,
              AppTokens.space16,
              AppTokens.space16 + bottomInset,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
