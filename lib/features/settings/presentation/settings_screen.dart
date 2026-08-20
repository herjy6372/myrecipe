import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_info_provider.dart';
import 'locale_provider.dart';
import 'static_text_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _languageLabel(Locale? locale) {
    switch (locale?.languageCode) {
      case 'ko':
        return '한국어';
      case 'en':
        return 'English';
      default:
        return '시스템 설정 따름';
    }
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final current = ref.read(localeOverrideProvider);
    final selected = await showModalBottomSheet<Locale?>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: RadioGroup<Locale?>(
            groupValue: current,
            onChanged: (v) => Navigator.of(context).pop(v),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<Locale?>(title: Text('시스템 설정 따름'), value: null),
                RadioListTile<Locale?>(title: Text('한국어'), value: Locale('ko')),
                RadioListTile<Locale?>(title: Text('English'), value: Locale('en')),
              ],
            ),
          ),
        );
      },
    );
    if (selected == current) return;
    ref.read(localeOverrideProvider.notifier).setLocale(selected);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeOverride = ref.watch(localeOverrideProvider);
    final appInfoAsync = ref.watch(appInfoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('언어 설정'),
            subtitle: Text(_languageLabel(localeOverride)),
            onTap: () => _pickLanguage(context, ref),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('개인정보 처리방침'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const StaticTextScreen(title: '개인정보 처리방침', content: privacyPolicyText),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('이용약관'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StaticTextScreen(title: '이용약관', content: termsOfServiceText)),
            ),
          ),
          const Divider(height: 1),
          appInfoAsync.when(
            loading: () => const ListTile(title: Text('기기정보'), subtitle: Text('불러오는 중...')),
            error: (error, _) => const ListTile(title: Text('기기정보'), subtitle: Text('불러오지 못했어요')),
            data: (info) => ListTile(
              leading: const Icon(Icons.smartphone_outlined),
              title: const Text('기기정보'),
              subtitle: Text(info.deviceName),
            ),
          ),
          appInfoAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (error, _) => const SizedBox.shrink(),
            data: (info) => ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('앱 버전'),
              subtitle: Text('${info.version} (${info.buildNumber})'),
            ),
          ),
        ],
      ),
    );
  }
}
