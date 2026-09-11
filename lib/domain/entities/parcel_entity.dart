enum MoistureStatus { optimal, dry, critical }

class GeoCoordinate {
  final double latitude;
  final double longitude;
  const GeoCoordinate({required this.latitude, required this.longitude});
}

class ParcelEntity {
  final String id;
  final String name;
  final String cropType;
  final double soilMoisture;
  final double soilTemperature;
  final String valveId;
  final bool isValveOpen;
  final List<GeoCoordinate> boundaries;

  const ParcelEntity({
    required this.id,
    required this.name,
    required this.cropType,
    required this.soilMoisture,
    required this.soilTemperature,
    required this.valveId,
    required this.isValveOpen,
    required this.boundaries,
  });

  MoistureStatus get status {
    if (soilMoisture < 20.0) return MoistureStatus.critical;
    if (soilMoisture <= 40.0) return MoistureStatus.dry;
    return MoistureStatus.optimal;
  }
}