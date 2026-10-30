import 'dart:convert';
import 'package:excel/excel.dart';

/// Reads tabular rows from raw CSV or Excel bytes.
final class WorkforceTabularReader {
  const WorkforceTabularReader();

  List<List<String>> read(String filename, List<int> bytes) {
    return filename.toLowerCase().endsWith('.csv') ? _csv(bytes) : _xlsx(bytes);
  }

  List<List<String>> _xlsx(List<int> bytes) {
    final excel = Excel.decodeBytes(bytes);
    final sheet =
        excel.tables['All Labour Active'] ?? excel.tables.values.firstOrNull;
    if (sheet == null) return const [];
    return sheet.rows
        .map((row) => row.map((cell) => cell?.value?.toString() ?? '').toList())
        .toList();
  }

  List<List<String>> _csv(List<int> bytes) {
    final text = utf8.decode(bytes, allowMalformed: false);
    final result = <List<String>>[];
    var row = <String>[];
    final field = StringBuffer();
    var quoted = false;
    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      if (char == '"') {
        if (quoted && i + 1 < text.length && text[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          quoted = !quoted;
        }
      } else if (!quoted && char == ',') {
        row.add(field.toString());
        field.clear();
      } else if (!quoted && (char == '\n' || char == '\r')) {
        if (char == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
        row.add(field.toString());
        field.clear();
        result.add(row);
        row = <String>[];
      } else {
        field.write(char);
      }
    }
    if (quoted) throw const FormatException('CSV contains an unclosed quote');
    if (field.isNotEmpty || row.isNotEmpty) {
      row.add(field.toString());
      result.add(row);
    }
    return result;
  }
}
