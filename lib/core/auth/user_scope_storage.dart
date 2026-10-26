import 'package:radar_labor/core/constants/app_constants.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

/// Helper to persist user team and housing scopes into Drift database.
Future<void> insertUserScopes(
  AppDatabase database,
  String userId,
  List<String> teamIds,
  List<String> housingIds,
) async {
  const uuid = Uuid();
  for (final (type, sid) in [
    for (final tid in teamIds) (ScopeTypes.team, tid),
    for (final hid in housingIds) (ScopeTypes.housing, hid),
  ]) {
    await database
        .into(database.userScopes)
        .insert(
          UserScopesCompanion.insert(
            id: uuid.v4(),
            userId: userId,
            scopeType: type,
            scopeId: sid,
          ),
        );
  }
}
