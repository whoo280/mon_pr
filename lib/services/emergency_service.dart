class Emergency {
  final String id;
  final String description;
  final String emergencyType;
  final double latitude;
  final double longitude;
  final String wilayaCode;
  final String wilayaName;
  final DateTime timestamp;

  Emergency({
    required this.id,
    required this.description,
    required this.emergencyType,
    required this.latitude,
    required this.longitude,
    required this.wilayaCode,
    required this.wilayaName,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'emergencyType': emergencyType,
      'latitude': latitude,
      'longitude': longitude,
      'wilayaCode': wilayaCode,
      'wilayaName': wilayaName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Emergency.fromMap(Map<String, dynamic> map) {
    return Emergency(
      id: map['id'],
      description: map['description'],
      emergencyType: map['emergencyType'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      wilayaCode: map['wilayaCode'],
      wilayaName: map['wilayaName'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}