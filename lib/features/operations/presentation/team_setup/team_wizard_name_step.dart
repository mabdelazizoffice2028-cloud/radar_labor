import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

/// Step 1 of Team Setup Wizard: Arabic & optional English team name (PRD §7.2).
final class TeamWizardNameStep extends StatelessWidget {
  const TeamWizardNameStep({
    required this.arabic,
    required this.nameAr,
    required this.nameEn,
    required this.onNameArChanged,
    required this.onNameEnChanged,
    required this.onNext,
    super.key,
  });

  final bool arabic;
  final String nameAr;
  final String nameEn;
  final ValueChanged<String> onNameArChanged;
  final ValueChanged<String> onNameEnChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppTokens.space16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          OperationsStrings.wizardStepOf(arabic, 1, 3),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppTokens.space16),
        TextFormField(
          initialValue: nameAr,
          maxLength: OperationsConstants.teamNameMaxLength,
          decoration: InputDecoration(
            labelText: OperationsStrings.teamNameArabicLabel(arabic),
            border: const OutlineInputBorder(),
          ),
          onChanged: onNameArChanged,
        ),
        const SizedBox(height: AppTokens.space12),
        TextFormField(
          initialValue: nameEn,
          maxLength: OperationsConstants.teamNameMaxLength,
          decoration: InputDecoration(
            labelText: OperationsStrings.teamNameEnglishLabel(arabic),
            border: const OutlineInputBorder(),
          ),
          onChanged: onNameEnChanged,
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: onNext,
          icon: const Icon(Icons.arrow_forward),
          label: Text(OperationsStrings.wizardNext(arabic)),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(AppTokens.minTouchTarget),
          ),
        ),
      ],
    ),
  );
}
