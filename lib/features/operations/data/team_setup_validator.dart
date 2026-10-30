import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/name_collation.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';

final class TeamSetupValidator {
  static final RegExp whitespace = RegExp(r'\s+');

  static Future<({String nameAr, String? nameEn})> validate({
    required AppDatabase database,
    required String nameAr,
    String? nameEn,
  }) async {
    final normAr = nameAr.trim().replaceAll(whitespace, ' ');
    final normEn = nameEn?.trim().replaceAll(whitespace, ' ');
    if (normAr.isEmpty || normAr.length > OperationsConstants.teamNameMaxLength) {
      throw const OperationException(TeamNameInvalid());
    }
    if (normEn != null && normEn.length > OperationsConstants.teamNameMaxLength) {
      throw const OperationException(TeamNameInvalid());
    }

    final existingTeams = await database.select(database.teams).get();
    final keyAr = NameCollation.sortKey(normAr);
    final keyEn = (normEn != null && normEn.isNotEmpty) ? NameCollation.sortKey(normEn) : null;

    for (final existing in existingTeams) {
      if (NameCollation.sortKey(existing.nameAr) == keyAr) {
        throw const OperationException(TeamNameExists());
      }
      if (keyEn != null && existing.nameEn != null && NameCollation.sortKey(existing.nameEn!) == keyEn) {
        throw const OperationException(TeamNameExists());
      }
    }
    return (nameAr: normAr, nameEn: (normEn == null || normEn.isEmpty) ? null : normEn);
  }
}
