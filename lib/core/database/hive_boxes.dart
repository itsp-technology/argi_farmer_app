import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/sync_command.dart';

class HiveBoxes {
  static const String parcelBox = 'parcels_cache';
  static const String queueBox = 'sync_queue';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SyncCommandAdapter());
    await Hive.openBox<Map>(parcelBox);
    await Hive.openBox<SyncCommand>(queueBox);
  }
}