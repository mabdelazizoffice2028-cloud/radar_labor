import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/constants/operations_constants.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/core/ui/field_haptics.dart';
import 'package:radar_labor/features/operations/domain/operations_models.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_notifier.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';
import 'package:radar_labor/features/operations/presentation/widgets/housing_worker_tile.dart';
import 'package:radar_labor/features/operations/presentation/widgets/operation_confirm_sync_dialog.dart';
import 'package:radar_labor/features/operations/presentation/widgets/operation_sync_helper.dart';
import 'package:radar_labor/features/operations/presentation/widgets/operation_whatsapp_dialog.dart';
import 'package:radar_labor/features/operations/presentation/widgets/unsaved_changes_guard.dart';

/// Dedicated full-screen Campus Absences check screen with back navigation.
final class HousingCheckScreen extends ConsumerStatefulWidget {
  const HousingCheckScreen({
    required this.controller,
    required this.arabic,
    this.actor,
    this.scope,
    super.key,
  });

  final OperationsController controller;
  final bool arabic;
  final ActorContext? actor;
  final ScopeSnapshot? scope;

  @override
  ConsumerState<HousingCheckScreen> createState() => _HousingCheckScreenState();
}

final class _HousingCheckScreenState extends ConsumerState<HousingCheckScreen> {
  @override
  Widget build(BuildContext context) {
    final ar = widget.arabic;
    final notifier = ref.read(housingCheckNotifierProvider.notifier);
    final state = ref.watch(housingCheckNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(OperationsStrings.startCampusCheckAction(ar))),
      body: UnsavedChangesGuard(
        hasUnsavedChanges: state.hasUnsavedChanges,
        persistDraft: notifier.flushDraft,
        arabic: ar,
        child: StreamBuilder<List<EntityOption>>(
          stream: widget.controller.watchHousings(),
          builder: (context, housingSnapshot) {
            final housings = housingSnapshot.data ?? const <EntityOption>[];
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) unawaited(notifier.ensureInitialHousing(housings));
            });

            final selected = state.selectedHousing;
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.space16,
                    vertical: AppTokens.space8,
                  ),
                  color: AppTokens.statusUnknownSoft,
                  child: Text(
                    OperationsStrings.selectAbsentWorkersHint(ar),
                    style: const TextStyle(
                      color: AppTokens.statusUnknown,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(AppTokens.space8),
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                if (housings.length > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.space12,
                      vertical: AppTokens.space4,
                    ),
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
                        final next = housings
                            .where((h) => h.id == id)
                            .firstOrNull;
                        unawaited(notifier.selectHousing(next));
                      },
                    ),
                  ),
                if (selected != null && state.rows.isNotEmpty)
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            AppTokens.radius12,
                          ),
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
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : selected == null
                      ? Center(
                          child: Text(OperationsStrings.addHousingToStart(ar)),
                        )
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
                              searchQuery: state.searchQuery,
                              onStateChanged: (_) {
                                unawaited(FieldHaptics.attendanceChanged());
                                notifier.toggleAbsent(row.worker.id);
                              },
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
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AppTokens.space8),
                        FilledButton(
                          onPressed: state.isSaving || selected == null
                              ? null
                              : () => _handleSave(selected),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                          ),
                          child: Text(OperationsStrings.nextConfirmAction(ar)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleSave(EntityOption housing) async {
    final ar = widget.arabic;
    final notifier = ref.read(housingCheckNotifierProvider.notifier);
    final state = ref.read(housingCheckNotifierProvider);

    final check = await notifier.prepareSave(
      controller: widget.controller,
      arabic: ar,
    );
    if (check == null || !mounted) return;

    final absentWorkers = state.rows
        .where((r) => r.isAbsent)
        .map((r) => r.worker)
        .toList();

    final action = await OperationConfirmSyncDialog.show(
      context: context,
      title: OperationsStrings.confirmHousingCheckTitle(ar),
      entityName: housing.displayName(arabic: ar),
      date: state.selectedDate,
      countSummaryText: OperationsStrings.markedAbsentCount(
        ar,
        state.absentCount,
      ),
      selectedWorkers: absentWorkers,
      emptySelectionText: OperationsStrings.noAbsencesSaveCheck(ar),
      arabic: ar,
    );
    if (action == null || !mounted) return;

    final undo = await notifier.confirmSave(
      controller: widget.controller,
      check: check,
    );
    if (undo == null || !mounted) return;

    if (action == ConfirmSaveAction.saveAndSync) {
      await performOperationSync(
        ref: ref,
        context: context,
        actor: widget.actor,
        scope: widget.scope,
        arabic: ar,
      );
    } else {
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
    }

    if (!mounted) return;
    await showOperationWhatsappDialog(
      context: context,
      messageText: check.summary.messageText,
      arabic: ar,
    );

    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}
