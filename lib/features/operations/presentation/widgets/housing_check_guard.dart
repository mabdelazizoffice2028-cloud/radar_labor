import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/ui/app_snack_bar.dart';
import 'package:radar_labor/core/ui/field_haptics.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';
import 'package:radar_labor/features/operations/domain/scope_guard.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_saver.dart';

Future<bool> guardHousingAction({
  required BuildContext context,
  required WidgetRef ref,
  required ActorContext? actor,
  required ScopeSnapshot? scope,
  required String selectedDate,
  required String todayDate,
  required bool arabic,
}) async {
  if (actor == null || scope == null) {
    return true;
  }
  try {
    final hour = await ref.read(housingLockoutHourProvider.future);
    ScopeGuard.guardHousingRecord(
      actor: actor,
      scope: scope,
      housingId: HousingCheckSaver.defaultHousing.id,
      date: selectedDate,
      todayBusinessDate: todayDate,
      nowUtc: ref.read(clockProvider).nowUtc(),
      lockoutHour: hour,
    );
    return true;
  } on OperationException catch (e) {
    await FieldHaptics.error();
    if (context.mounted) {
      AppSnackBar.showError(
        context,
        message: OperationFailureMessage.of(e.failure, arabic),
      );
    }
    return false;
  }
}
