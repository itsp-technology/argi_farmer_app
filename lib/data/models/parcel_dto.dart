import '../../domain/entities/parcel_entity.dart';

class ParcelDto {
  final String id;
  final String name;
  final String cropType;
  final double soilMoisture;
  final double soilTemperature;
  final String valveId;
  final bool isValveOpen;
  final List<Map<String, double>> boundaries;

  ParcelDto({
    required this.id,
    required this.name,
    required this.cropType,
    required this.soilMoisture,
    required this.soilTemperature,
    required this.valveId,
    required this.isValveOpen,
    required this.boundaries,
  });

  factory ParcelDto.fromJson(Map<String, dynamic> json) {
    var rawCoords = json['boundaries'] as List? ?? [];
    List<Map<String, double>> parsedCoords = rawCoords.map((c) {
      return {
        'lat': (c['lat'] as num).toDouble(),
        'lng': (c['lng'] as num).toDouble(),
      };
    }).toList();

    return ParcelDto(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Unnamed Parcel',
      cropType: json['cropType'] as String? ?? 'General Crop',
      soilMoisture: (json['soilMoisture'] as num? ?? 0.0).toDouble(),
      soilTemperature: (json['soilTemperature'] as num? ?? 0.0).toDouble(),
      valveId: json['valveId'] as String? ?? '',
      isValveOpen: json['isValveOpen'] as bool? ?? false,
      boundaries: parsedCoords,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cropType': cropType,
        'soilMoisture': soilMoisture,
        'soilTemperature': soilTemperature,
        'valveId': valveId,
        'isValveOpen': isValveOpen,
        'boundaries': boundaries,
      };

  ParcelEntity toEntity() {
    return ParcelEntity(
      id: id,
      name: name,
      cropType: cropType,
      soilMoisture: soilMoisture,
      soilTemperature: soilTemperature,
      valveId: valveId,
      isValveOpen: isValveOpen,
      boundaries: boundaries
          .map((b) => GeoCoordinate(latitude: b['lat']!, longitude: b['lng']!))
          .toList(),
    );
  }
}