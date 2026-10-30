import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/auth/scope_snapshot.dart';
import 'package:radar_labor/core/l10n/operations_strings.dart';
import 'package:radar_labor/core/time/business_date.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';
import 'package:radar_labor/features/operations/presentation/state/housing_check_notifier.dart';
import 'package:radar_labor/features/operations/presentation/state/operations_controller.dart';
import 'package:radar_labor/features/operations/presentation/widgets/housing_check_bottom_bar.dart';
import 'package:radar_labor/features/operations/presentation/widgets/housing_check_dialog_helper.dart';
import 'package:radar_labor/features/operations/presentation/widgets/housing_check_header.dart';
import 'package:radar_labor/features/operations/presentation/widgets/housing_check_list_view.dart';
import 'package:radar_labor/features/operations/presentation/widgets/unsaved_changes_guard.dart';

final class HousingCheckScreen extends ConsumerStatefulWidget {
  const HousingCheckScreen({
    required this.controller, required this.arabic, this.actor, this.scope, super.key,
  });
  final OperationsController controller;
  final bool arabic; final ActorContext? actor; final ScopeSnapshot? scope;

  @override
  ConsumerState<HousingCheckScreen> createState() => _HousingCheckScreenState();
}

final class _HousingCheckScreenState extends ConsumerState<HousingCheckScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(housingCheckNotifierProvider.notifier).loadDefaultHousing();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ar = widget.arabic;
    final notifier = ref.read(housingCheckNotifierProvider.notifier);
    final state = ref.watch(housingCheckNotifierProvider);
    final isFriday = isFridayBusinessDate(state.selectedDate);

    return Scaffold(
      appBar: AppBar(title: Text(OperationsStrings.startCampusCheckAction(ar))),
      body: UnsavedChangesGuard(
        hasUnsavedChanges: state.hasUnsavedChanges,
        persistDraft: notifier.flushDraft, arabic: ar,
        child: Column(
          children: [
            HousingCheckHeader(
              arabic: ar, searchQuery: state.searchQuery, isFriday: isFriday,
              onSearchChanged: notifier.setSearchQuery, isSaving: state.isSaving,
              onNoAbsencesPressed: () => HousingCheckDialogHelper.handleNoAbsences(
                context: context, ref: ref, controller: widget.controller,
                notifier: notifier, state: state, arabic: ar, actor: widget.actor, scope: widget.scope,
              ),
            ),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(AppTokens.space8),
                child: Text(state.errorMessage!, style: const TextStyle(color: AppTokens.statusUnknown)),
              ),
            Expanded(
              child: HousingCheckListView(
                state: state, arabic: ar, onToggleAbsent: isFriday ? (_) {} : notifier.toggleAbsent,
              ),
            ),
            HousingCheckBottomBar(
              arabic: ar, absentCount: state.absentCount, isSaving: state.isSaving, isFriday: isFriday,
              onSavePressed: () => HousingCheckDialogHelper.handleSave(
                context: context, ref: ref, controller: widget.controller,
                notifier: notifier, state: state, arabic: ar, actor: widget.actor, scope: widget.scope,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
