import 'package:dio/dio.dart';
import '../models/parcel_dto.dart';

abstract class IFarmRemoteDataSource {
  Future<List<ParcelDto>> fetchParcels();
  Future<void> patchAttribute({
    required String entityId,
    required String attribute,
    required dynamic value,
  });
}

class FarmRemoteDataSourceImpl implements IFarmRemoteDataSource {
  final Dio dio;
  FarmRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ParcelDto>> fetchParcels() async {
    // Queries the backend gateway which pulls from Scorpio Broker
    final response = await dio.get('/api/v1/parcels');
    return (response.data as List)
        .map((json) => ParcelDto.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  @override
  Future<void> patchAttribute({
    required String entityId,
    required String attribute,
    required dynamic value,
  }) async {
    await dio.patch(
      '/api/v1/entities/$entityId/attrs/$attribute',
      data: {'value': value},
    );
  }
}