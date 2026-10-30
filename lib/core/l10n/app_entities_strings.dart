abstract final class AppEntitiesStrings {
  static String addWorker(bool ar) => ar ? 'إضافة عامل' : 'Add worker';
  static String searchWorker(bool ar) =>
      ar ? 'بحث بالاسم أو الرقم' : 'Search name or code';
  static String noWorkersYet(bool ar) =>
      ar ? 'لا يوجد عمال بعد — اضغط إضافة' : 'No workers yet — tap Add';
  static String workerCode(bool ar) => ar ? 'رقم العامل' : 'Worker code';
  static String arabicName(bool ar) => ar ? 'الاسم بالعربية' : 'Arabic name';
  static String englishName(bool ar) =>
      ar ? 'الاسم بالإنجليزية' : 'English name';
  static String currentTeam(bool ar) => ar ? 'الفريق الحالي' : 'Current team';
  static String currentHousing(bool ar) =>
      ar ? 'الكامبوس الحالي' : 'Current CAMPOS';
  static String noTeam(bool ar) => ar ? 'بدون فريق' : 'No team';
  static String noHousing(bool ar) => ar ? 'بدون كامبوس' : 'No CAMPOS';
  static String markOnSite(bool ar) => ar ? 'تسجيل بالموقع' : 'Mark on site';
  static String markAbsent(bool ar) => ar ? 'تسجيل غياب' : 'Mark absent';
  static String assignTeamHousingFirst(bool ar) => ar
      ? 'عيّن العامل إلى فريق وكامبوس أولاً'
      : 'Assign the worker to a team and CAMPOS first';
  static String workerCodeExists(bool ar) =>
      ar ? 'رقم العامل مستخدم بالفعل' : 'Worker code already exists';
  static String workerSaveFailed(bool ar) => ar
      ? 'تعذر حفظ العامل. حاول مرة أخرى.'
      : 'Could not save the worker. Please try again.';
  static String addTeam(bool ar) => ar ? 'إضافة فريق' : 'Add team';
  static String addHousing(bool ar) => ar ? 'إضافة كامبوس' : 'Add CAMPOS';
  static String add(bool ar) => ar ? 'إضافة' : 'Add';
  static String noDataYet(bool ar) =>
      ar ? 'لا توجد بيانات بعد' : 'No data yet';
  static String unknownError(bool ar) =>
      ar ? 'حدث خطأ غير متوقع. حاول مرة أخرى.' : 'An unexpected error occurred. Please try again.';
}
