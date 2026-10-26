import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

/// Choice tile option for same-day conflict resolution (Phase 6).
class ConflictChoiceTile extends StatelessWidget {
  const ConflictChoiceTile({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppTokens.space4),
      child: Material(
        color: selected ? AppTokens.primarySoft : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radius12),
          side: BorderSide(
            color: selected ? AppTokens.primary : AppTokens.outline,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTokens.radius12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.space8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selected
                        ? AppTokens.primary
                        : AppTokens.statusNotRecorded,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppTokens.space8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: AppTokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
