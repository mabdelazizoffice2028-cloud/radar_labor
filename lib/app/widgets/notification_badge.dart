import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/widgets/notification_providers.dart';
import 'package:radar_labor/app/widgets/notifications_sheet.dart';
import 'package:radar_labor/core/l10n/notifications_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class NotificationBadge extends ConsumerWidget {
  const NotificationBadge({required this.arabic, super.key});
  final bool arabic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAlerts = ref.watch(hasUnrecordedOrPendingProvider);

    return Semantics(
      label: NotificationsStrings.centerLabel(arabic),
      button: true,
      child: IconButton(
        icon: Badge(
          isLabelVisible: hasAlerts,
          backgroundColor: AppTokens.statusUnknown,
          smallSize: AppTokens.space8,
          child: const Icon(Icons.notifications_outlined),
        ),
        tooltip: NotificationsStrings.centerTitle(arabic),
        onPressed: () => NotificationsSheet.show(context, arabic: arabic),
      ),
    );
  }
}
