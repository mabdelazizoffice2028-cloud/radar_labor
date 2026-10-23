import 'package:flutter/services.dart';

final class PickedWorkforceFile {
  const PickedWorkforceFile({required this.name, required this.bytes});
  final String name;
  final Uint8List bytes;
}

final class WorkforceFilePicker {
  static const _channel = MethodChannel('radar_labor/workforce_files');

  Future<PickedWorkforceFile?> pick() async {
    final result = await _channel.invokeMapMethod<String, Object?>('pick');
    if (result == null) return null;
    final name = result['name'];
    final bytes = result['bytes'];
    if (name is! String || bytes is! Uint8List) {
      throw const FormatException('The selected file could not be read');
    }
    return PickedWorkforceFile(name: name, bytes: bytes);
  }
}
