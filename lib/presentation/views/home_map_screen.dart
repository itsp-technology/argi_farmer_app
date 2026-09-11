import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/parcel_controller.dart';
import 'widgets/parcel_card.dart';
import 'widgets/plot_map_layer.dart';

class HomeMapScreen extends ConsumerStatefulWidget {
  const HomeMapScreen({super.key});

  @override
  ConsumerState<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends ConsumerState<HomeMapScreen> {
  final MapController _mapController = MapController();
  bool _cameraInitialized = false;

  void _fitBounds(parcels) {
    if (_cameraInitialized || parcels.isEmpty) return;

    List<LatLng> allPoints = [];
    for (var p in parcels) {
      for (var b in p.boundaries) {
        allPoints.add(LatLng(b.latitude, b.longitude));
      }
    }

    if (allPoints.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(allPoints),
            padding: const EdgeInsets.only(top: 80, bottom: 260, left: 40, right: 40),
          ),
        );
        _cameraInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final parcelState = ref.watch(parcelControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF070B19),
      body: parcelState.when(
        data: (parcels) {
          _fitBounds(parcels);

          return Stack(
            children: [
              // 1. Futuristic High-Res Satellite Map Layer
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: LatLng(28.4080, 77.3150),
                  initialZoom: 16.5,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                    userAgentPackageName: 'com.agri.farmer.app',
                  ),
                  PlotMapLayer(
                    parcels: parcels,
                    onPlotSelected: (p) {},
                  ),
                ],
              ),

              // 2. Futuristic Top HUD Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    bottom: 12,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF070B19).withOpacity(0.95),
                        const Color(0xFF070B19).withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00FF9D).withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF00FF9D)),
                            ),
                            child: const Icon(Icons.satellite_alt_rounded,
                                color: Color(0xFF00FF9D), size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "SCORPIO TELEMETRY",
                                style: TextStyle(
                                  color: Color(0xFF00FF9D),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                "Smart Farm AI Cockpit",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xDD0D1B2A),
                          side: const BorderSide(color: Colors.white24),
                        ),
                        icon: const Icon(Icons.my_location_rounded, color: Colors.cyanAccent),
                        onPressed: () {
                          _cameraInitialized = false;
                          _fitBounds(parcels);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Floating Cockpit Control Cards
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 210,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: parcels.length,
                    itemBuilder: (context, index) {
                      final item = parcels[index];
                      return SizedBox(
                        width: MediaQuery.of(context).size.width > 600
                            ? 380
                            : MediaQuery.of(context).size.width * 0.88,
                        child: ParcelCard(
                          parcel: item,
                          onToggleValve: (turnOn) {
                            ref
                                .read(parcelControllerProvider.notifier)
                                .toggleValve(item.id, item.valveId, turnOn);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF00FF9D)),
        ),
        error: (err, stack) => Center(
          child: Text('Telemetry Sync Error: $err',
              style: const TextStyle(color: Colors.redAccent)),
        ),
      ),
    );
  }
}