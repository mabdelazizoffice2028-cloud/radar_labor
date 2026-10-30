import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:radar_labor/app/accounts/account_form_submitter.dart';
import 'package:radar_labor/app/home_scaffold_section_meta.dart';
import 'package:radar_labor/core/auth/auth_role.dart';
import 'package:radar_labor/core/auth/role_capabilities.dart';
import 'package:radar_labor/core/l10n/about_app_content_data.dart';
import 'package:radar_labor/core/ui/app_tokens.dart';

void main() {
  group('Radar Labour V2.7 Architecture & QA', () {
    test('AboutAppContentData uses professional Arabic terms without campus', () {
      final aboutAr = AboutAppContentData.forLanguage('ar');
      expect(aboutAr.overviewBody.contains('سكن العمال'), isTrue);
      expect(aboutAr.overviewBody.contains('الكامبوس'), isFalse);
      expect(aboutAr.campusTitle, 'مشرف سكن العمال (Housing Supervisor)');
      expect(aboutAr.campusBody.contains('السبت إلى الخميس'), isTrue);
      expect(aboutAr.lockoutBody.contains('مدير المشروع والإدارة'), isTrue);
    });

    test('Admin role has users section in bottom navigation', () {
      final admin = AuthRole.projectManager.capabilities;
      expect(admin.sections, contains(AppSection.users));
      expect(admin.sections.contains(AppSection.dashboard), isTrue);
      expect(HomeScaffoldSectionMeta.iconForSection(AppSection.users), Icons.manage_accounts_outlined);
      expect(HomeScaffoldSectionMeta.labelForSection(AppSection.users, true), 'المستخدمين');
      expect(HomeScaffoldSectionMeta.labelForSection(AppSection.users, false), 'Users');
    });

    test('AccountFormSubmitter zeroes out employeeUid for viewer role', () {
      final result = AccountFormSubmitter.buildResult(
        isAdding: true,
        employeeUid: 'EMP-999',
        initialEmployeeUid: 'EMP-999',
        displayName: 'General Auditor',
        role: AuthRole.viewer,
        teams: {'team-1'},
      );
      expect(result.employeeUid, isNull);
      expect(result.displayName, 'General Auditor');
      expect(result.role, AuthRole.viewer);
      expect(result.teamIds, isEmpty);
    });

    test('AppTokens define pure white onPrimary and surface', () {
      expect(AppTokens.surface, const Color(0xFFFFFFFF));
      expect(AppTokens.onPrimary, const Color(0xFFFFFFFF));
    });
  });
}
