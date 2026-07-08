class FarmModel {
  final int? id;

  final String farmName;
  final String cropType;
  final String farmArea;
  final String farmImagePath;
  final String latitude;
  final String longitude;
  final String insuranceStatus;

  // Offline Sync Fields
  final String? clientUuid;
  final String syncSource;
  final String? capturedAt;

  FarmModel({
    this.id,
    required this.farmName,
    required this.cropType,
    required this.farmArea,
    required this.farmImagePath,
    required this.latitude,
    required this.longitude,
    required this.insuranceStatus,

    this.clientUuid,
    this.syncSource = 'online',
    this.capturedAt,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: json['id'],

      farmName: json['farm_name'] ?? '',
      cropType: json['crop_type'] ?? '',
      farmArea: json['farm_area'].toString(),
      farmImagePath: json['farm_image_path'] ?? '',
      latitude: json['latitude'].toString(),
      longitude: json['longitude'].toString(),
      insuranceStatus: json['insurance_status'] ?? '',

      clientUuid: json['client_uuid'],
      syncSource: json['sync_source'] ?? 'online',
      capturedAt: json['captured_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,

      'farm_name': farmName,
      'crop_type': cropType,
      'farm_area': farmArea,
      'farm_image_path': farmImagePath,
      'latitude': latitude,
      'longitude': longitude,
      'insurance_status': insuranceStatus,

      'client_uuid': clientUuid,
      'sync_source': syncSource,
      'captured_at': capturedAt,
    };
  }
}
