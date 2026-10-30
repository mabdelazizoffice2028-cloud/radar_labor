import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/database/app_database.dart';
import 'package:radar_labor/core/l10n/app_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class WorkerAddDialogView extends StatefulWidget {
  const WorkerAddDialogView({
    required this.codeController, required this.nameController,
    required this.teams, required this.arabic, super.key,
  });

  final TextEditingController codeController, nameController;
  final List<Team> teams;
  final bool arabic;

  @override
  State<WorkerAddDialogView> createState() => WorkerAddDialogViewState();
}

final class WorkerAddDialogViewState extends State<WorkerAddDialogView> {
  String? teamId;
  String? get selectedTeamId => teamId;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(AppStrings.addWorker(widget.arabic)),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.codeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(labelText: AppStrings.workerCode(widget.arabic)),
          ),
          TextField(
            controller: widget.nameController,
            decoration: InputDecoration(labelText: AppStrings.englishName(widget.arabic)),
          ),
          const SizedBox(height: AppTokens.space12),
          DropdownButtonFormField<String?>(
            initialValue: teamId,
            decoration: InputDecoration(labelText: AppStrings.currentTeam(widget.arabic)),
            items: [
              DropdownMenuItem<String?>(value: null, child: Text(AppStrings.noTeam(widget.arabic))),
              ...widget.teams.map((t) => DropdownMenuItem(value: t.teamId, child: Text(t.nameEn ?? t.nameAr))),
            ],
            onChanged: (v) => setState(() => teamId = v),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppStrings.cancel(widget.arabic))),
      FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(AppStrings.save(widget.arabic))),
    ],
  );
}
