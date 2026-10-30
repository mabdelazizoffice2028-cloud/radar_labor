import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/widgets/notification_providers.dart';
import 'package:radar_labor/app/widgets/notifications_coverage_section.dart';
import 'package:radar_labor/app/widgets/notifications_sync_section.dart';
import 'package:radar_labor/core/l10n/notifications_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class NotificationsSheet extends ConsumerWidget {
  const NotificationsSheet({required this.arabic, super.key});
  final bool arabic;

  static Future<void> show(BuildContext context, {required bool arabic}) => showModalBottomSheet<void>(
    context: context, isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.space20))),
    builder: (_) => NotificationsSheet(arabic: arabic),
  );

  Widget _header(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(NotificationsStrings.centerTitle(arabic), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
    ],
  );

  Widget _allGoodCard() => Card(
    color: AppTokens.statusOnSiteSoft,
    child: Padding(
      padding: const EdgeInsets.all(AppTokens.space16),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppTokens.statusOnSite),
          const SizedBox(width: AppTokens.space12),
          Expanded(
            child: Text(
              NotificationsStrings.allComplete(arabic),
              style: const TextStyle(color: AppTokens.statusOnSite, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coverage = ref.watch(todayCoverageProvider).asData?.value;
    final allRecorded = coverage != null && coverage.missingTeams.isEmpty && coverage.missingHousings.isEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppTokens.space16, AppTokens.space12, AppTokens.space16, AppTokens.space16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(context),
              const SizedBox(height: AppTokens.space8),
              NotificationsSyncSection(arabic: arabic),
              const SizedBox(height: AppTokens.space8),
              if (coverage != null) NotificationsCoverageSection(coverage: coverage, arabic: arabic),
              if (allRecorded) _allGoodCard(),
            ],
          ),
        ),
      ),
    );
  }
}
