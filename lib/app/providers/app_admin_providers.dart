import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/app/providers/app_core_providers.dart';
import 'package:radar_labor/core/audit/audit_log_repository.dart';
import 'package:radar_labor/core/leaves/leave_repository.dart';
import 'package:radar_labor/features/operations/data/roster_admin_repository.dart';

final auditLogRepositoryProvider = Provider<AuditLogRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final clock = ref.watch(clockProvider);
  return AuditLogRepository(database: db, clock: clock);
});

final rosterAdminRepositoryProvider = Provider<RosterAdminRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final audit = ref.watch(auditLogRepositoryProvider);
  final auth = ref.watch(localAuthRepositoryProvider);
  return RosterAdminRepository(database: db, audit: audit, auth: auth);
});

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  final settings = ref.watch(settingsRepositoryProvider);
  final audit = ref.watch(auditLogRepositoryProvider);
  return LeaveRepository(settings: settings, audit: audit);
});
