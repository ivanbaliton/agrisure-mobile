class ClaimModel {
  final int id;
  final int damageReportId;
  final String status;
  final String? inspectionDate;
  final String? claimAmount;
  final String? claimSchedule;
  final String? claimVenue;

  final String farmName;
  final String cropType;
  final String farmArea;
  final String damageCause;
  final String damageDate;

  ClaimModel({
    required this.id,
    required this.damageReportId,
    required this.status,
    this.inspectionDate,
    this.claimAmount,
    this.claimSchedule,
    this.claimVenue,
    required this.farmName,
    required this.cropType,
    required this.farmArea,
    required this.damageCause,
    required this.damageDate,
  });

  factory ClaimModel.fromJson(Map<String, dynamic> json) {
    final damageReport = json['damage_report'] ?? {};
    final farm = damageReport['farm'] ?? {};

    return ClaimModel(
      id: json['id'],
      damageReportId: json['damage_report_id'],
      status: json['status'] ?? '',
      inspectionDate: json['inspection_date'],
      claimAmount: json['claim_amount']?.toString(),
      claimSchedule: json['claim_schedule'],
      claimVenue: json['claim_venue'],
      farmName: farm['farm_name'] ?? '',
      cropType: farm['crop_type'] ?? '',
      farmArea: farm['farm_area']?.toString() ?? '',
      damageCause: damageReport['damage_cause'] ?? '',
      damageDate: damageReport['damage_date'] ?? '',
    );
  }
}
