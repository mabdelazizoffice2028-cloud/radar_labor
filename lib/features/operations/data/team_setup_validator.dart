import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/name_collation.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';

final class TeamSetupValidator {
  static final RegExp whitespace = RegExp(r'\s+');

  static Future<({String nameAr, String nameEn})> validate({
    required AppDatabase database,
    required String nameAr,
    String? nameEn,
  }) async {
    final cleanAr = nameAr.trim().replaceAll(whitespace, ' ');
    final cleanEn = (nameEn != null && nameEn.trim().isNotEmpty)
        ? nameEn.trim().replaceAll(whitespace, ' ')
        : cleanAr;
    final resolvedAr = cleanAr.isNotEmpty ? cleanAr : cleanEn;
    final targetName = cleanEn.isNotEmpty ? cleanEn : resolvedAr;

    if (targetName.isEmpty || targetName.length > OperationsConstants.teamNameMaxLength) {
      throw const OperationException(TeamNameInvalid());
    }

    final existingTeams = await database.select(database.teams).get();
    final keyAr = NameCollation.sortKey(resolvedAr);
    final keyEn = NameCollation.sortKey(cleanEn);

    for (final existing in existingTeams) {
      final exKeyAr = NameCollation.sortKey(existing.nameAr);
      final exKeyEn = existing.nameEn != null ? NameCollation.sortKey(existing.nameEn!) : exKeyAr;
      if (exKeyAr == keyAr || exKeyAr == keyEn || exKeyEn == keyAr || exKeyEn == keyEn) {
        throw const OperationException(TeamNameExists());
      }
    }
    return (nameAr: resolvedAr, nameEn: cleanEn);
  }
}
