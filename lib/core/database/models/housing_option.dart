/// Lightweight model representing housing campus reference data.
final class HousingOption {
  const HousingOption({
    required this.housingId,
    required this.nameAr,
    this.nameEn,
  });

  final String housingId;
  final String nameAr;
  final String? nameEn;
}
