import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/widgets/notification_providers.dart';
import 'package:radar_labor/app/widgets/notifications_sheet.dart';

final class NotificationBadge extends ConsumerWidget {
  const NotificationBadge({required this.arabic, super.key});
  final bool arabic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAlerts = ref.watch(hasUnrecordedOrPendingProvider);

    return Semantics(
      label: arabic ? 'التنبيهات' : 'Notifications',
      button: true,
      child: IconButton(
        icon: Badge(
          isLabelVisible: hasAlerts,
          backgroundColor: Colors.red.shade600,
          smallSize: 8,
          child: const Icon(Icons.notifications_outlined),
        ),
        tooltip: arabic ? 'مركز التنبيهات' : 'Notification Center',
        onPressed: () => NotificationsSheet.show(context, arabic: arabic),
      ),
    );
  }
}
