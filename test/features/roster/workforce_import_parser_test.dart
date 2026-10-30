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

  test('csv_readsEmploymentTypeIndependentlyOfSupplier', () {
    final rows = parser.parse(
      filename: 'workers.csv',
      bytes: utf8.encode(
        'S/O,Name,Designation,Supplier,Employment Type\n'
        'A-1,أحمد,Driver,Vendor Co,company\n'
        'A-2,خالد,Helper,Vendor Co,rental\n'
        'A-3,سالم,Carpenter,Vendor Co,\n'
        'A-4,ياسر,Mason,,شركة\n'
        'A-5,عمر,Welder,,إيجار\n',
      ),
    );

    expect(rows, hasLength(5));
    expect(rows[0].employmentType, 'company');
    expect(rows[0].supplier, 'Vendor Co');

    expect(rows[1].employmentType, 'rental');
    expect(rows[1].supplier, 'Vendor Co');

    expect(rows[2].employmentType, 'rental');
    expect(rows[3].employmentType, 'company');
    expect(rows[4].employmentType, 'rental');
  });
}
