import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';

final scopedSiteTeamsProvider = StreamProvider<List<EntityOption>>((ref) {
  final session = ref.watch(currentSessionProvider);
  if (session == null) return Stream.value(const <EntityOption>[]);
  final scopesAsync = ref.watch(userScopesProvider(session.id));
  final allowedIds = scopesAsync.value?.teamIds ?? session.teamIds.toSet();
  return ref.watch(siteAttendanceStoreProvider).watchScopedTeams(allowedIds);
});
