class InsuranceApplicationModel {
  final int id;
  final int farmId;

  final double insuredArea;
  final double coveredFreeArea;
  final double excessArea;
  final double freeCoverageBefore;
  final double freeCoverageAfter;
  final double premiumAmount;

  final String paymentStatus;
  final String? paymentMethod;
  final String? paymentProofPath;
  final String? gcashReferenceNumber;

  final String civilStatus;
  final String beneficiaryName;
  final String? spouseName;
  final String? parentGuardianName;

  final String variety;
  final String farmType;

  final String? sowingDate;
  final String? transplantingDate;

  final String northBoundary;
  final String eastBoundary;
  final String westBoundary;
  final String southBoundary;

  final bool isLandOwner;
  final String tenureStatus;

  final String applicationDate;
  final String status;
  final String? remarks;

  InsuranceApplicationModel({
    required this.id,
    required this.farmId,
    required this.insuredArea,
    required this.coveredFreeArea,
    required this.excessArea,
    required this.freeCoverageBefore,
    required this.freeCoverageAfter,
    required this.premiumAmount,
    required this.paymentStatus,
    this.paymentMethod,
    this.paymentProofPath,
    this.gcashReferenceNumber,
    required this.civilStatus,
    required this.beneficiaryName,
    this.spouseName,
    this.parentGuardianName,
    required this.variety,
    required this.farmType,
    this.sowingDate,
    this.transplantingDate,
    required this.northBoundary,
    required this.eastBoundary,
    required this.westBoundary,
    required this.southBoundary,
    required this.isLandOwner,
    required this.tenureStatus,
    required this.applicationDate,
    required this.status,
    this.remarks,
  });

  factory InsuranceApplicationModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return InsuranceApplicationModel(
      id: json['id'],
      farmId: json['farm_id'],

      insuredArea: toDouble(json['insured_area']),
      coveredFreeArea: toDouble(json['covered_free_area']),
      excessArea: toDouble(json['excess_area']),
      freeCoverageBefore: toDouble(json['free_coverage_before']),
      freeCoverageAfter: toDouble(json['free_coverage_after']),
      premiumAmount: toDouble(json['premium_amount']),

      paymentStatus: json['payment_status'] ?? 'not_required',
      paymentMethod: json['payment_method'],
      paymentProofPath: json['payment_proof_path'],
      gcashReferenceNumber: json['gcash_reference_number'],

      civilStatus: json['civil_status'] ?? '',
      beneficiaryName: json['beneficiary_name'] ?? '',
      spouseName: json['spouse_name'],
      parentGuardianName: json['parent_guardian_name'],

      variety: json['variety'] ?? '',
      farmType: json['farm_type'] ?? '',

      sowingDate: json['sowing_date'],
      transplantingDate: json['transplanting_date'],

      northBoundary: json['north_boundary'] ?? '',
      eastBoundary: json['east_boundary'] ?? '',
      westBoundary: json['west_boundary'] ?? '',
      southBoundary: json['south_boundary'] ?? '',

      isLandOwner:
          json['is_land_owner'] == true ||
          json['is_land_owner'] == 1 ||
          json['is_land_owner'] == '1',

      tenureStatus: json['tenure_status'] ?? '',
      applicationDate: json['application_date'] ?? '',
      status: json['status'] ?? '',
      remarks: json['remarks'],
    );
  }
}
