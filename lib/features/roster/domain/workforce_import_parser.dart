import 'dart:convert';

import 'package:excel/excel.dart';
import 'package:radar_labor/features/roster/domain/workforce_row.dart';

/// Reads only the non-sensitive workforce columns needed for local operations.
final class WorkforceImportParser {
  const WorkforceImportParser();

  List<WorkforceRow> parse({
    required String filename,
    required List<int> bytes,
  }) {
    final lowerName = filename.toLowerCase();
    final rows = lowerName.endsWith('.csv') ? _csv(bytes) : _xlsx(bytes);
    if (rows.isEmpty) throw const FormatException('No tabular data found');
    final headerIndex = rows.indexWhere(_isHeader);
    if (headerIndex < 0) {
      throw const FormatException('Required S/O and Name columns are missing');
    }
    final headers = rows[headerIndex].map(_normalizeHeader).toList();
    final codeIndex = headers.indexOf('so');
    final nameIndex = headers.indexOf('name');
    final designationIndex = headers.indexOf('designation');
    final supplierIndex = headers.indexOf('supplier');
    final result = <WorkforceRow>[];
    for (final row in rows.skip(headerIndex + 1)) {
      final code = _cell(row, codeIndex);
      final name = _cell(row, nameIndex);
      if (code.isEmpty && name.isEmpty) continue;
      if (code.isEmpty || name.isEmpty) {
        throw const FormatException('A worker row has a missing code or name');
      }
      result.add(
        WorkforceRow(
          code: code,
          name: name,
          designation: _cell(row, designationIndex),
          supplier: _cell(row, supplierIndex),
        ),
      );
    }
    if (result.isEmpty) throw const FormatException('No workers found');
    final codes = <String>{};
    for (final worker in result) {
      if (!codes.add(worker.code.toLowerCase())) {
        throw const FormatException(
          'Duplicate worker codes must be fixed first',
        );
      }
    }
    return List.unmodifiable(result);
  }

  bool _isHeader(List<String> row) {
    final headers = row.map(_normalizeHeader).toSet();
    return headers.contains('so') && headers.contains('name');
  }

  String _normalizeHeader(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  String _cell(List<String> row, int index) =>
      index < 0 || index >= row.length ? '' : row[index].trim();

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
    for (var index = 0; index < text.length; index++) {
      final char = text[index];
      if (char == '"') {
        if (quoted && index + 1 < text.length && text[index + 1] == '"') {
          field.write('"');
          index++;
        } else {
          quoted = !quoted;
        }
      } else if (!quoted && char == ',') {
        row.add(field.toString());
        field.clear();
      } else if (!quoted && (char == '\n' || char == '\r')) {
        if (char == '\r' &&
            index + 1 < text.length &&
            text[index + 1] == '\n') {
          index++;
        }
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
