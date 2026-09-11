import 'package:hive/hive.dart';

part 'sync_command.g.dart';

@HiveType(typeId: 0)
class SyncCommand extends HiveObject {
  @HiveField(0)
  final String commandId;

  @HiveField(1)
  final String entityId;

  @HiveField(2)
  final String attributeName;

  @HiveField(3)
  final String payloadValue;

  @HiveField(4)
  final DateTime queuedAt;

  @HiveField(5)
  int retryCount;

  SyncCommand({
    required this.commandId,
    required this.entityId,
    required this.attributeName,
    required this.payloadValue,
    required this.queuedAt,
    this.retryCount = 0,
  });
}