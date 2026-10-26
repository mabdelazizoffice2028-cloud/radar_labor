import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _featureSegment = RegExp(r'features/([a-z0-9_]+)/');

const _impureImports = [
  'package:flutter',
  'dart:ui',
  'package:drift',
  'package:riverpod',
  'package:flutter_riverpod',
  'package:sqlite3',
];

List<File> _sources() {
  final lib = Directory('lib');
  if (!lib.existsSync()) return const [];
  return lib
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'))
      .toList();
}

String _norm(File file) => file.path.replaceAll(r'\', '/');

List<String> _directives(File file) => file
    .readAsLinesSync()
    .map((l) => l.trimLeft())
    .where((l) => l.startsWith('import ') || l.startsWith('export '))
    .toList();

List<String> _filesWithDirective(
  bool Function(File) scope,
  bool Function(String) isViolation,
) {
  return [
    for (final file in _sources().where(scope))
      if (_directives(file).any(isViolation)) _norm(file),
  ];
}

void main() {
  test('features_doNotImportOtherFeatures', () {
    final violations = <String>[];
    for (final file in _sources()) {
      final owner = _featureSegment.firstMatch(_norm(file))?.group(1);
      if (owner == null) continue;
      final importsOther = _directives(file).any((line) {
        final target = _featureSegment.firstMatch(line)?.group(1);
        return target != null && target != owner;
      });
      if (importsOther) violations.add(_norm(file));
    }
    expect(violations, isEmpty);
  });

  test('coreStatus_isPureDart', () {
    final violations = _filesWithDirective(
      (f) => _norm(f).contains('lib/core/status/'),
      (line) => _impureImports.any(line.contains),
    );
    expect(violations, isEmpty);
  });

  test('widgetFiles_doNotImportDatabaseOrSupabaseOrDrift', () {
    final violations = _filesWithDirective(
      (f) {
        final path = _norm(f);
        return path.contains('/presentation/') || path.contains('lib/core/ui/');
      },
      (line) =>
          line.contains('core/database') ||
          line.contains('supabase') ||
          line.contains('package:drift'),
    );
    expect(violations, isEmpty);
  });

  test('flutterMaterialAndCupertino_areNeverImported', () {
    final violations = _filesWithDirective(
      (_) => true,
      (line) =>
          line.contains('package:flutter/material.dart') ||
          line.contains('package:flutter/cupertino.dart'),
    );
    expect(violations, isEmpty);
  });

  test('systemClock_isReadOnlyInsideCoreTime', () {
    final violations = _sources()
        .where((f) => !_norm(f).contains('lib/core/time/'))
        .where((f) => f.readAsStringSync().contains('DateTime.now('))
        .map(_norm)
        .toList();
    expect(violations, isEmpty);
  });
}
