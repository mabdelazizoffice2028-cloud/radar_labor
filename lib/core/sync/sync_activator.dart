import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/database/app_setting_keys.dart';
import 'package:radar_labor/core/sync/remote_gateway.dart';
import 'package:radar_labor/features/operations/domain/operation_failure.dart';

final class SyncActivator {
  const SyncActivator({required this.database, required this.gateway});

  final AppDatabase database;
  final RemoteSyncGateway gateway;

  Future<void> ensureActivated({required ActorContext actor}) async {
    if (actor.role == AuthRole.projectManager || actor.role == AuthRole.hr) {
      return;
    }
    final row = await (database.select(database.settings)
          ..where((s) => s.key.equals(AppSettingKeys.deviceActivated)))
        .getSingleOrNull();
    if (row?.value == 'true') return;

    final hasEmployees = (await database.select(database.employees).get()).isNotEmpty;
    if (hasEmployees) {
      await markActivated();
      return;
    }

    if (!await gateway.isReachable()) {
      throw const OperationException(ActivationRequired());
    }
  }

  Future<int> readLocalEpoch() async {
    final row = await (database.select(database.settings)
          ..where((s) => s.key.equals(AppSettingKeys.rosterEpoch)))
        .getSingleOrNull();
    return int.tryParse(row?.value ?? '1') ?? 1;
  }

  Future<void> markActivated() async {
    await database.into(database.settings).insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: AppSettingKeys.deviceActivated,
            value: 'true',
          ),
        );
  }
}
