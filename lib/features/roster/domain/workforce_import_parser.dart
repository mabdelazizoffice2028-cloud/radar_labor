import 'package:radar_labor/features/roster/domain/workforce_row.dart';
import 'package:radar_labor/features/roster/domain/workforce_tabular_reader.dart';

/// Reads non-sensitive workforce columns needed for local operations.
final class WorkforceImportParser {
  const WorkforceImportParser({this.reader = const WorkforceTabularReader()});
  final WorkforceTabularReader reader;

  List<WorkforceRow> parse({required String filename, required List<int> bytes}) {
    final rows = reader.read(filename, bytes);
    if (rows.isEmpty) throw const FormatException('No tabular data found');
    final headerIndex = rows.indexWhere(_isHeader);
    if (headerIndex < 0) throw const FormatException('Required S/O and Name columns are missing');
    final headers = rows[headerIndex].map(_normalizeHeader).toList();
    final cIdx = headers.indexOf('so'), nIdx = headers.indexOf('name');
    final dIdx = headers.indexOf('designation'), sIdx = headers.indexOf('supplier');
    final rIdx = _firstIndex(headers, const ['role', 'approle', 'systemrole']);
    final tIdx = _firstIndex(headers, const ['team', 'teamname']);
    final cpIdx = _firstIndex(headers, const ['campus', 'campusname', 'housing', 'camp']);
    final etIdx = _firstIndex(headers, const ['employmenttype', 'type', 'affiliation', 'نوعالتبعية', 'التبعية']);
    final result = <WorkforceRow>[];
    for (final row in rows.skip(headerIndex + 1)) {
      final code = _cell(row, cIdx), name = _cell(row, nIdx);
      if (code.isEmpty && name.isEmpty) continue;
      if (code.isEmpty || name.isEmpty) throw const FormatException('A worker row has a missing code or name');
      final supp = _cell(row, sIdx);
      result.add(WorkforceRow(
        code: code, name: name, designation: _cell(row, dIdx), supplier: supp,
        employmentType: _resolveType(_cell(row, etIdx), supp),
        role: _cell(row, rIdx), team: _cell(row, tIdx), campus: _cell(row, cpIdx),
      ));
    }
    if (result.isEmpty) throw const FormatException('No workers found');
    final codes = <String>{};
    for (final w in result) {
      if (!codes.add(w.code.toLowerCase())) throw const FormatException('Duplicate worker codes must be fixed first');
    }
    return List.unmodifiable(result);
  }

  bool _isHeader(List<String> r) => r.map(_normalizeHeader).toSet().containsAll(const {'so', 'name'});
  String _normalizeHeader(String v) => v.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF]'), '');
  int _firstIndex(List<String> h, List<String> c) => c.map(h.indexOf).firstWhere((i) => i >= 0, orElse: () => -1);
  String _cell(List<String> r, int idx) => idx < 0 || idx >= r.length ? '' : r[idx].trim();

  static String _resolveType(String raw, String supplier) {
    final lower = raw.trim().toLowerCase();
    if (lower.contains('rental') || lower.contains('ايجار') || lower.contains('إيجار')) return 'rental';
    if (lower.contains('company') || lower.contains('شركة')) return 'company';
    return supplier.trim().isNotEmpty ? 'rental' : 'company';
  }
}
