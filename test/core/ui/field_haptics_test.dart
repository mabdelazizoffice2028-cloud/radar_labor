import 'package:flutter_test/flutter_test.dart';
import 'package:radar_labor/core/ui/field_haptics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('FieldHaptics safe wrappers complete cleanly without error', () async {
    await expectLater(FieldHaptics.attendanceChanged(), completes);
    await expectLater(FieldHaptics.success(), completes);
    await expectLater(FieldHaptics.error(), completes);
    await expectLater(FieldHaptics.selection(), completes);
  });
}
