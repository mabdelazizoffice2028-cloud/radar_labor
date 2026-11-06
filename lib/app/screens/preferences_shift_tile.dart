import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/shift_settings_strings.dart';

final class ShiftTimeTile extends StatelessWidget {
  const ShiftTimeTile({
    required this.title,
    required this.minuteValue,
    required this.arabic,
    required this.onChanged,
    super.key,
  });

  final String title;
  final int minuteValue;
  final bool arabic;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = [for (var m = 0; m < 1440; m += 30) m];
    if (!items.contains(minuteValue)) {
      items.add(minuteValue);
      items.sort();
    }
    return Card(
      child: ListTile(
        leading: const Icon(Icons.schedule_outlined),
        title: Text(title),
        trailing: DropdownButton<int>(
          value: minuteValue,
          items: [
            for (final m in items)
              DropdownMenuItem(
                value: m,
                child: Text(ShiftSettingsStrings.timeFormat(m, arabic)),
              ),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
