import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:radar_labor/app/app_providers.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/features/dashboard/data/dashboard_coverage_repository.dart';

final todayCoverageProvider = StreamProvider<DashboardCoverage>((ref) {
  final repo = ref.watch(dashboardCoverageRepositoryProvider);
  final clock = ref.watch(clockProvider);
  return repo.watch(businessDateFor(clock.nowUtc()));
});

final hasUnrecordedOrPendingProvider = Provider<bool>((ref) {
  final coverage = ref.watch(todayCoverageProvider).asData?.value;
  final pending = ref.watch(pendingOutboxCountProvider).asData?.value ?? 0;
  if (pending > 0) return true;
  if (coverage == null) return false;
  return coverage.missingTeams.isNotEmpty || coverage.missingHousings.isNotEmpty;
});
