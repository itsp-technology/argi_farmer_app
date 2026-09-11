import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../domain/entities/parcel_entity.dart';

class PlotMapLayer extends StatelessWidget {
  final List<ParcelEntity> parcels;
  final ValueChanged<ParcelEntity> onPlotSelected;

  const PlotMapLayer({
    super.key,
    required this.parcels,
    required this.onPlotSelected,
  });

  Color _getStatusFill(MoistureStatus status) {
    switch (status) {
      case MoistureStatus.critical:
        return const Color(0x77FF1744); // Glowing Neon Red
      case MoistureStatus.dry:
        return const Color(0x77FF9100); // Glowing Neon Amber
      case MoistureStatus.optimal:
        return const Color(0x6600E676); // Glowing Neon Green
    }
  }

  Color _getStatusBorder(MoistureStatus status) {
    switch (status) {
      case MoistureStatus.critical:
        return const Color(0xFFFF1744);
      case MoistureStatus.dry:
        return const Color(0xFFFF9100);
      case MoistureStatus.optimal:
        return const Color(0xFF00E676);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PolygonLayer(
          polygons: parcels.map((parcel) {
            return Polygon(
              points: parcel.boundaries
                  .map((b) => LatLng(b.latitude, b.longitude))
                  .toList(),
              color: _getStatusFill(parcel.status),
              borderColor: _getStatusBorder(parcel.status),
              borderStrokeWidth: 3.5,
            );
          }).toList(),
        ),
        MarkerLayer(
          markers: parcels.map((parcel) {
            final centerLat = parcel.boundaries
                    .map((c) => c.latitude)
                    .reduce((a, b) => a + b) /
                parcel.boundaries.length;
            final centerLng = parcel.boundaries
                    .map((c) => c.longitude)
                    .reduce((a, b) => a + b) /
                parcel.boundaries.length;

            return Marker(
              point: LatLng(centerLat, centerLng),
              width: 140,
              height: 44,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xDD0D1B2A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getStatusBorder(parcel.status),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusBorder(parcel.status).withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    parcel.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}