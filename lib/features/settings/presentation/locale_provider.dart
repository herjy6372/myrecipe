import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/cache/hive_boxes.dart';

const supportedAppLocales = [Locale('ko'), Locale('en')];

/// null이면 "시스템 설정을 따름". 값이 있으면 사용자가 명시적으로 고른 언어.
class LocaleOverrideNotifier extends StateNotifier<Locale?> {
  LocaleOverrideNotifier() : super(_readSaved());

  static const _key = 'locale_override';

  static Locale? _readSaved() {
    final code = Hive.box(HiveBoxes.settings).get(_key) as String?;
    if (code == null) return null;
    return Locale(code);
  }

  void setLocale(Locale? locale) {
    state = locale;
    final box = Hive.box(HiveBoxes.settings);
    if (locale == null) {
      box.delete(_key);
    } else {
      box.put(_key, locale.languageCode);
    }
  }
}

final localeOverrideProvider = StateNotifierProvider<LocaleOverrideNotifier, Locale?>((ref) {
  return LocaleOverrideNotifier();
});
