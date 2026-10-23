enum AuthRole { projectManager, hr, housingSupervisor, siteSupervisor, viewer }

extension AuthRoleLabel on AuthRole {
  String label({required bool arabic}) => switch (this) {
    AuthRole.projectManager => arabic ? 'مدير المشروع' : 'Project manager',
    AuthRole.hr => arabic ? 'الموارد البشرية' : 'HR',
    AuthRole.housingSupervisor => arabic ? 'مشرف السكن' : 'Housing supervisor',
    AuthRole.siteSupervisor => arabic ? 'مشرف الموقع' : 'Site supervisor',
    AuthRole.viewer => arabic ? 'مشاهد فقط' : 'View only',
  };
}
