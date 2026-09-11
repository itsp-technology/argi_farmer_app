import 'package:flutter/material.dart';
import '../../../domain/entities/parcel_entity.dart';

class ParcelCard extends StatelessWidget {
  final ParcelEntity parcel;
  final Function(bool) onToggleValve;

  const ParcelCard({
    super.key,
    required this.parcel,
    required this.onToggleValve,
  });

  Color _getStatusColor() {
    switch (parcel.status) {
      case MoistureStatus.critical:
        return const Color(0xFFFF2A55);
      case MoistureStatus.dry:
        return const Color(0xFFFFB300);
      case MoistureStatus.optimal:
        return const Color(0xFF00FF9D);
    }
  }

  String _getStatusText() {
    switch (parcel.status) {
      case MoistureStatus.critical:
        return "CRITICAL: NEEDS WATER NOW";
      case MoistureStatus.dry:
        return "LOW MOISTURE: WATCH";
      case MoistureStatus.optimal:
        return "SOIL HEALTHY";
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xEE0B132B), // Futuristic Deep Space Navy Glass
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.7), width: 2),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.25),
            blurRadius: 16,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header: Field Name & Status Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parcel.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    "Crop: ${parcel.cropType}",
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      parcel.status == MoistureStatus.critical
                          ? Icons.warning_rounded
                          : Icons.check_circle_rounded,
                      color: statusColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getStatusText(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Center Stats: Circular Moisture Gauge & Temperature HUD
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Moisture Radial Badge
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: CircularProgressIndicator(
                          value: (parcel.soilMoisture / 100).clamp(0.0, 1.0),
                          strokeWidth: 6,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        ),
                      ),
                      const Icon(Icons.water_drop_rounded, color: Colors.cyanAccent, size: 24),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("SOIL MOISTURE",
                          style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                      Text(
                        "${parcel.soilMoisture.toStringAsFixed(1)}%",
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  )
                ],
              ),

              // Temperature Gauge
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orangeAccent.withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.thermostat_rounded, color: Colors.orangeAccent, size: 26),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("GROUND TEMP",
                          style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
                      Text(
                        "${parcel.soilTemperature.toStringAsFixed(1)}°C",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),

          // Big Farmer-Friendly Action Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: parcel.isValveOpen
                    ? const Color(0xFFFF1744) // Red to STOP
                    : const Color(0xFF00E676), // Bright Green to START
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 6,
              ),
              onPressed: () => onToggleValve(!parcel.isValveOpen),
              icon: Icon(
                parcel.isValveOpen ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded,
                color: Colors.black,
                size: 24,
              ),
              label: Text(
                parcel.isValveOpen ? "PUMP IS RUNNING • TAP TO STOP" : "TAP TO START WATER PUMP",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}