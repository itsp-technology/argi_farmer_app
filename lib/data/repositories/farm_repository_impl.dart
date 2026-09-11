import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/parcel_entity.dart';
import '../../domain/repositories/i_farm_repository.dart';
import '../datasources/farm_local_data_source.dart';
import '../datasources/farm_remote_data_source.dart';
import '../models/parcel_dto.dart';
import '../models/sync_command.dart';

class FarmRepositoryImpl implements IFarmRepository {
  final IFarmRemoteDataSource remoteSource;
  final IFarmLocalDataSource localSource;
  final INetworkInfo networkInfo;
  final _streamController = StreamController<List<ParcelEntity>>.broadcast();

  FarmRepositoryImpl({
    required this.remoteSource,
    required this.localSource,
    required this.networkInfo,
  });

  @override
  Stream<List<ParcelEntity>> watchParcels() {
    _emitLocalCache();
    _fetchFromRemote();
    return _streamController.stream;
  }

  void _emitLocalCache() {
    final cached = localSource.getCachedParcels();
    if (cached.isNotEmpty) {
      _streamController.add(cached.map((dto) => dto.toEntity()).toList());
    }
  }

  Future<void> _fetchFromRemote() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteData = await remoteSource.fetchParcels();
        await localSource.cacheParcels(remoteData);
        _streamController.add(remoteData.map((d) => d.toEntity()).toList());
      } catch (_) {
        // Fall back gracefully to cache
      }
    }
  }

  @override
  Future<Either<Failure, void>> toggleValve({
    required String parcelId,
    required String valveId,
    required bool turnOn,
  }) async {
    // 1. Optimistic UI update
    final cached = localSource.getCachedParcels();
    final updated = cached.map((p) {
      if (p.id == parcelId) {
        return ParcelDto(
          id: p.id,
          name: p.name,
          cropType: p.cropType,
          soilMoisture: p.soilMoisture,
          soilTemperature: p.soilTemperature,
          valveId: p.valveId,
          isValveOpen: turnOn,
          boundaries: p.boundaries,
        );
      }
      return p;
    }).toList();

    await localSource.cacheParcels(updated);
    _streamController.add(updated.map((e) => e.toEntity()).toList());

    // 2. Queue the command for Scorpio Broker sync
    final command = SyncCommand(
      commandId: DateTime.now().millisecondsSinceEpoch.toString(),
      entityId: valveId,
      attributeName: 'status',
      payloadValue: turnOn ? 'ON' : 'OFF',
      queuedAt: DateTime.now(),
    );
    await localSource.enqueueCommand(command);

    // 3. Flush if online
    if (await networkInfo.isConnected) {
      unawaited(flushSyncQueue());
    }

    return const Right(null);
  }

  @override
  Future<void> flushSyncQueue() async {
    final pending = localSource.getPendingCommands();
    for (final cmd in pending) {
      try {
        await remoteSource.patchAttribute(
          entityId: cmd.entityId,
          attribute: cmd.attributeName,
          value: cmd.payloadValue,
        );
        await localSource.removeCommand(cmd.commandId);
      } catch (e) {
        cmd.retryCount++;
        await cmd.save();
        break; // Pause FIFO sync until connectivity restores completely
      }
    }
  }
}