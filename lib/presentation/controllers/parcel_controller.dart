import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../core/database/hive_boxes.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../data/datasources/farm_local_data_source.dart';
import '../../data/datasources/farm_remote_data_source.dart';
import '../../data/models/sync_command.dart';
import '../../data/repositories/farm_repository_impl.dart';
import '../../domain/entities/parcel_entity.dart';
import '../../domain/repositories/i_farm_repository.dart';

final farmRepositoryProvider = Provider<IFarmRepository>((ref) {
  final dio = ApiClient.createDio();
  final parcelBox = Hive.box<Map>(HiveBoxes.parcelBox);
  final queueBox = Hive.box<SyncCommand>(HiveBoxes.queueBox);

  return FarmRepositoryImpl(
    remoteSource: FarmRemoteDataSourceImpl(dio),
    localSource: FarmLocalDataSourceImpl(parcelBox: parcelBox, queueBox: queueBox),
    networkInfo: NetworkInfoImpl(Connectivity()),
  );
});

class ParcelController extends AsyncNotifier<List<ParcelEntity>> {
  late final IFarmRepository _repository;
  StreamSubscription? _subscription;

  @override
  FutureOr<List<ParcelEntity>> build() {
    _repository = ref.watch(farmRepositoryProvider);

    _subscription?.cancel();
    _subscription = _repository.watchParcels().listen(
      (parcels) => state = AsyncData(parcels),
      onError: (err, stack) => state = AsyncError(err, stack),
    );

    ref.onDispose(() => _subscription?.cancel());
    return [];
  }

  Future<void> toggleValve(String parcelId, String valveId, bool turnOn) async {
    await _repository.toggleValve(
      parcelId: parcelId,
      valveId: valveId,
      turnOn: turnOn,
    );
  }
}

final parcelControllerProvider =
    AsyncNotifierProvider<ParcelController, List<ParcelEntity>>(
  ParcelController.new,
);