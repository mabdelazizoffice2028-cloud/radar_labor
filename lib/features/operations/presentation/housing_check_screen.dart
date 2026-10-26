import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/l10n/housing_review_strings.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_notifier.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';
import 'package:radar_labor/features/operations/presentation/widgets/housing_worker_tile.dart';

/// 3-State Housing check screen for housing supervisors and admins (Phase 4).
final class HousingCheckScreen extends ConsumerStatefulWidget {
  const HousingCheckScreen({
    required this.controller,
    required this.arabic,
    super.key,
  });

  final OperationsController controller;
  final bool arabic;

  @override
  ConsumerState<HousingCheckScreen> createState() => _HousingCheckScreenState();
}

final class _HousingCheckScreenState extends ConsumerState<HousingCheckScreen> {
  @override
  Widget build(BuildContext context) {
    final ar = widget.arabic;
    final notifier = ref.read(housingCheckNotifierProvider.notifier);
    final state = ref.watch(housingCheckNotifierProvider);

    return StreamBuilder<List<EntityOption>>(
      stream: widget.controller.watchHousings(),
      builder: (context, housingSnapshot) {
        final housings = housingSnapshot.data ?? const <EntityOption>[];
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) unawaited(notifier.ensureInitialHousing(housings));
        });

        final selected = state.selectedHousing;
        return Column(
          children: [
            if (housings.length > 1)
              Padding(
                padding: const EdgeInsets.all(AppTokens.space16),
                child: DropdownButtonFormField<String>(
                  initialValue: selected?.id,
                  decoration: InputDecoration(
                    labelText: OperationsStrings.selectHousing(ar),
                    border: const OutlineInputBorder(),
                  ),
                  items: housings
                      .map(
                        (h) => DropdownMenuItem(
                          value: h.id,
                          child: Text(h.displayName(arabic: ar)),
                        ),
                      )
                      .toList(),
                  onChanged: (id) {
                    final next = housings.where((h) => h.id == id).firstOrNull;
                    unawaited(notifier.selectHousing(next));
                  },
                ),
              ),
            if (selected != null && state.rows.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space12,
                  vertical: AppTokens.space4,
                ),
                child: TextField(
                  key: const ValueKey('housing_worker_search_field'),
                  decoration: InputDecoration(
                    hintText: OperationsStrings.searchWorkersHint(ar),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.space12,
                      vertical: AppTokens.space8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTokens.radius12),
                    ),
                    suffixIcon: state.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => notifier.setSearchQuery(''),
                          )
                        : null,
                  ),
                  onChanged: notifier.setSearchQuery,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space12,
                  vertical: AppTokens.space4,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${HousingReviewStrings.reviewedCountLabel(ar, state.reviewedCount)} • '
                        '${HousingReviewStrings.absentCountLabel(ar, state.absentCount)} • '
                        '${HousingReviewStrings.unreviewedCountLabel(ar, state.unreviewedCount)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTokens.textSecondary,
                        ),
                      ),
                    ),
                    if (state.unreviewedCount > 0)
                      TextButton.icon(
                        key: const ValueKey('mark_remaining_button'),
                        onPressed: notifier.markRemainingAsReviewed,
                        icon: const Icon(Icons.done_all, size: 18),
                        label: Text(
                          HousingReviewStrings.markRemainingAsReviewed(ar),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : selected == null
                  ? Center(child: Text(OperationsStrings.addHousingToStart(ar)))
                  : state.rows.isEmpty
                  ? Center(
                      child: Text(OperationsStrings.noWorkersInHousing(ar)),
                    )
                  : ListView.builder(
                      itemCount: state.filteredRows.length,
                      itemBuilder: (context, index) {
                        final row = state.filteredRows[index];
                        return HousingWorkerTile(
                          row: row,
                          arabic: ar,
                          onStateChanged: (nextState) =>
                              notifier.setReviewState(row.worker.id, nextState),
                        );
                      },
                    ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      OperationsStrings.markedAbsentCount(
                        ar,
                        state.absentCount,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTokens.space8),
                    FilledButton.icon(
                      onPressed: state.isSaving || selected == null
                          ? null
                          : () => _handleSave(selected),
                      icon: Icon(
                        state.absentCount == 0
                            ? Icons.check_circle_outline
                            : Icons.save_outlined,
                      ),
                      label: Text(
                        state.isSaving
                            ? OperationsStrings.savingLabel(ar)
                            : state.absentCount == 0
                            ? OperationsStrings.noAbsencesSaveCheck(ar)
                            : OperationsStrings.confirmAbsencesAndSave(ar),
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          AppTokens.minTouchTarget,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSave(EntityOption housing) async {
    final ar = widget.arabic;
    final notifier = ref.read(housingCheckNotifierProvider.notifier);
    final state = ref.read(housingCheckNotifierProvider);

    if (state.unreviewedCount > 0) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            HousingReviewStrings.unreviewedWorkersWarning(
              ar,
              state.unreviewedCount,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(OperationsStrings.reviewAction(ar)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(OperationsStrings.confirmAction(ar)),
            ),
          ],
        ),
      );
      if (proceed != true || !mounted) return;
      notifier.markRemainingAsReviewed();
    }

    final check = await notifier.prepareSave(
      controller: widget.controller,
      arabic: ar,
    );
    if (check == null || !mounted) return;

    final summary = check.summary;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(OperationsStrings.confirmHousingCheckTitle(ar)),
        content: Text(summary.confirmationText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(OperationsStrings.reviewAction(ar)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(OperationsStrings.confirmAction(ar)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final undo = await notifier.confirmSave(
      controller: widget.controller,
      check: check,
    );
    if (undo == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(OperationsStrings.housingSavedLocally(ar)),
        duration: OperationsConstants.undoWindow,
        action: SnackBarAction(
          label: OperationsStrings.undoAction(ar),
          onPressed: () =>
              unawaited(notifier.undoLastSave(controller: widget.controller)),
        ),
      ),
    );

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(OperationsStrings.whatsappSummaryTitle(ar)),
        content: SelectableText(summary.messageText),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: summary.messageText));
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(OperationsStrings.copyTextAction(ar)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(OperationsStrings.closeAction(ar)),
          ),
        ],
      ),
    );
  }
}
