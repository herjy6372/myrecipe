import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxes {
  static const searchCache = 'search_cache_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(searchCache);
  }
}
