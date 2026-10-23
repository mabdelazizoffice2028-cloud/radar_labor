import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/features/roster/domain/workforce_import_parser.dart';

void main() {
  const parser = WorkforceImportParser();

  test('csv_readsArabicNamesAndIgnoresIdentityColumn', () {
    final rows = parser.parse(
      filename: 'workers.csv',
      bytes: utf8.encode(
        'S/O,ID No.,Name,Designation,Supplier\nA-1,123456,أحمد,Driver,Vendor',
      ),
    );

    expect(rows, hasLength(1));
    expect(rows.single.code, 'A-1');
    expect(rows.single.name, 'أحمد');
    expect(rows.single.designation, 'Driver');
    expect(rows.single.supplier, 'Vendor');
  });

  test('duplicateCodes_areRejectedBeforeImport', () {
    expect(
      () => parser.parse(
        filename: 'workers.csv',
        bytes: utf8.encode('S/O,Name\nA-1,First\na-1,Second'),
      ),
      throwsFormatException,
    );
  });
}
