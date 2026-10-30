import 'package:radar_labor/app/accounts/account_form_dialog.dart';
import 'package:radar_labor/app/accounts/accounts_admin_controller.dart';
import 'package:radar_labor/core/auth/local_account.dart';

final class LocalAccountsDialogFactory {
  static AccountFormDialog create({
    required AccountsAdminData data,
    required bool arabic,
    LocalAccount? initial,
  }) {
    String label(String ar, String? en) => (en != null && en.trim().isNotEmpty) ? en : ar;
    return AccountFormDialog(
      arabic: arabic,
      initial: initial,
      employees: [
        for (final e in data.employees)
          (e.iqamaNo, label(e.fullNameAr, e.fullNameEn)),
      ],
      teams: [for (final t in data.teams) (t.teamId, label(t.nameAr, t.nameEn))],
      housings: [for (final h in data.housings) (h.housingId, label(h.nameAr, h.nameEn))],
    );
  }
}
