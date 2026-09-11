import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/parcel_entity.dart';

abstract class IFarmRepository {
  Stream<List<ParcelEntity>> watchParcels();
  Future<Either<Failure, void>> toggleValve({
    required String parcelId,
    required String valveId,
    required bool turnOn,
  });
  Future<void> flushSyncQueue();
}