import 'package:radar_labor/features/operations/domain/operations_models.dart';

enum HousingReviewState { unreviewed, reviewedPresent, absent }

final class HousingWorkerRow {
  const HousingWorkerRow({
    required this.worker,
    this.reviewState = HousingReviewState.unreviewed,
  });

  const HousingWorkerRow.binary({
    required WorkerOption worker,
    required bool isAbsent,
  }) : this(
         worker: worker,
         reviewState: isAbsent ? HousingReviewState.absent : HousingReviewState.reviewedPresent,
       );

  final WorkerOption worker;
  final HousingReviewState reviewState;

  bool get isAbsent => reviewState == HousingReviewState.absent;

  HousingWorkerRow copyWith({HousingReviewState? reviewState}) =>
      HousingWorkerRow(worker: worker, reviewState: reviewState ?? this.reviewState);
}
