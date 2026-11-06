import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/features/roster/domain/windows_1256_decoder.dart';
import 'package:radar_labor/features/roster/domain/workforce_import_parser.dart';
import 'package:radar_labor/features/roster/domain/workforce_tabular_reader.dart';

void main() {
  group('Windows1256Decoder (B-010)', () {
    test('accurately encodes and decodes Arabic characters and mixed text', () {
      const original = 'محمد علي - سائق شاحنة (شركة الموارد)';
      final encoded = Windows1256Decoder.encode(original);

      // Verify non-empty and contains expected high-bit bytes
      expect(encoded, isNotEmpty);
      expect(encoded.any((b) => b >= 0x80), isTrue);

      final decoded = Windows1256Decoder.decode(encoded);
      expect(decoded, original);
    });

    test('preserves ASCII characters identically', () {
      const asciiText = 'S/O,ID No.,Name,Designation,Supplier,Employment Type';
      final encoded = Windows1256Decoder.encode(asciiText);
      final decoded = Windows1256Decoder.decode(encoded);
      expect(decoded, asciiText);
    });
  });

  group('WorkforceTabularReader Windows-1256 CSV support', () {
    const reader = WorkforceTabularReader();

    test('reads Windows-1256 CSV transparently with automatic fallback', () {
      const csvContent =
          'S/O,Name,Designation\n'
          'W-1,عبد الرحمن,كهربائي\n'
          'W-2,محمود حسن,سباك\n';

      final bytes = Windows1256Decoder.encode(csvContent);

      // Verify that raw bytes fail standard UTF-8 parsing
      expect(() => Uri.decodeComponent(String.fromCharCodes(bytes)), anything);

      final rows = reader.read('roster.csv', bytes);
      expect(rows, hasLength(3));
      expect(rows[0], ['S/O', 'Name', 'Designation']);
      expect(rows[1], ['W-1', 'عبد الرحمن', 'كهربائي']);
      expect(rows[2], ['W-2', 'محمود حسن', 'سباك']);
    });
  });

  group('WorkforceImportParser with Windows-1256 (B-010)', () {
    const parser = WorkforceImportParser();

    test('parses Windows-1256 encoded CSV into structured workforce rows', () {
      const csvData =
          'S/O,ID No.,Name,Designation,Supplier,Employment Type\n'
          '101,2345678901,طارق زياد,مشغل رافعة,شركة المقاولات,company\n'
          '102,2345678902,ياسين حمزة,عامل مساعد,شركة الأفق,rental\n';

      final cp1256Bytes = Windows1256Decoder.encode(csvData);

      final parsed = parser.parse(filename: 'workforce_export_win1256.csv', bytes: cp1256Bytes);

      expect(parsed, hasLength(2));

      expect(parsed[0].code, '101');
      expect(parsed[0].name, 'طارق زياد');
      expect(parsed[0].designation, 'مشغل رافعة');
      expect(parsed[0].supplier, 'شركة المقاولات');
      expect(parsed[0].employmentType, 'company');

      expect(parsed[1].code, '102');
      expect(parsed[1].name, 'ياسين حمزة');
      expect(parsed[1].designation, 'عامل مساعد');
      expect(parsed[1].supplier, 'شركة الأفق');
      expect(parsed[1].employmentType, 'rental');
    });
  });
}
