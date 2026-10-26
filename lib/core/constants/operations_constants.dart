/// Domain and presentation constants for daily operations, history, and drafts.
abstract final class OperationsConstants {
  static const int maxBackdateDays = 7;
  static const int suggestionLookbackDays = 14;
  static const int draftRetentionDays = 14;
  static const Duration draftDebounce = Duration(milliseconds: 300);
  static const Duration searchDebounce = Duration(milliseconds: 250);
  static const Duration undoWindow = Duration(seconds: 8);
  static const int teamNameMaxLength = 60;
  static const int crossTeamSearchMinChars = 2;
  static const int crossTeamSearchMaxResults = 30;
  static const int historyPageDays = 14;
  static const int riyadhUtcOffsetHours = 3;
  static const int dayCutoffHour = 3;
}
