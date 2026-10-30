import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/role_capabilities.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/l10n/history_strings.dart';

final class HomeScaffoldSectionMeta {
  static IconData iconForSection(AppSection section) => switch (section) {
    AppSection.dashboard => Icons.dashboard_outlined,
    AppSection.workers => Icons.people_outline,
    AppSection.teams => Icons.groups_outlined,
    AppSection.checkIn => Icons.fact_check_outlined,
    AppSection.history => Icons.history_outlined,
    AppSection.settings => Icons.settings_outlined,
  };

  static String labelForSection(AppSection section, bool ar) => switch (section) {
    AppSection.dashboard => ar ? 'لوحة المتابعة' : 'Dashboard',
    AppSection.workers => ar ? 'العمال' : 'Workers',
    AppSection.teams => ar ? 'الفرق' : 'Teams',
    AppSection.checkIn => ar ? 'التسجيل اليومي' : 'Daily Check',
    AppSection.history => HistoryStrings.historyTab(ar),
    AppSection.settings => AppStrings.settingsTab(ar),
  };
}
