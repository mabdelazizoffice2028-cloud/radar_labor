import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/core/l10n/dev_tools_strings.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

final class PreferencesWipeDialog extends StatefulWidget {
  const PreferencesWipeDialog({required this.arabic, super.key});
  final bool arabic;

  @override
  State<PreferencesWipeDialog> createState() => _PreferencesWipeDialogState();
}

final class _PreferencesWipeDialogState extends State<PreferencesWipeDialog> {
  late final TextEditingController _controller;
  bool _canConfirm = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final expected = DevToolsStrings.confirmPhrase(widget.arabic);
    final matches = _controller.text.trim() == expected;
    if (matches != _canConfirm) setState(() => _canConfirm = matches);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(DevToolsStrings.confirmClearTitle(widget.arabic)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(DevToolsStrings.confirmClearBody(widget.arabic)),
            const SizedBox(height: AppTokens.space12),
            Text(
              DevToolsStrings.confirmInputHint(widget.arabic),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppTokens.space8),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(DevToolsStrings.cancel(widget.arabic)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTokens.statusUnknown,
            ),
            onPressed:
                _canConfirm ? () => Navigator.of(context).pop(true) : null,
            child: Text(DevToolsStrings.clearData(widget.arabic)),
          ),
        ],
      );
}
