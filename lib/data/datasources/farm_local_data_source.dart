import 'package:hive/hive.dart';
import '../models/parcel_dto.dart';
import '../models/sync_command.dart';

abstract class IFarmLocalDataSource {
  Future<void> cacheParcels(List<ParcelDto> parcels);
  List<ParcelDto> getCachedParcels();
  Future<void> enqueueCommand(SyncCommand command);
  List<SyncCommand> getPendingCommands();
  Future<void> removeCommand(String commandId);
}

class FarmLocalDataSourceImpl implements IFarmLocalDataSource {
  final Box<Map> parcelBox;
  final Box<SyncCommand> queueBox;

  FarmLocalDataSourceImpl({required this.parcelBox, required this.queueBox});

  @override
  Future<void> cacheParcels(List<ParcelDto> parcels) async {
    final Map<String, Map<String, dynamic>> map = {
      for (var p in parcels) p.id: p.toJson()
    };
    await parcelBox.putAll(map);
  }

  @override
  List<ParcelDto> getCachedParcels() {
    return parcelBox.values
        .map((e) => ParcelDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<void> enqueueCommand(SyncCommand command) async {
    await queueBox.put(command.commandId, command);
  }

  @override
  List<SyncCommand> getPendingCommands() => queueBox.values.toList();

  @override
  Future<void> removeCommand(String commandId) async {
    await queueBox.delete(commandId);
  }
}