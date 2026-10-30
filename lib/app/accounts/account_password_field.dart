import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';

final class AccountPasswordField extends StatelessWidget {
  const AccountPasswordField({
    required this.arabic,
    required this.controller,
    super.key,
  });

  final bool arabic;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: AppStrings.password(arabic),
        ),
      );
}
