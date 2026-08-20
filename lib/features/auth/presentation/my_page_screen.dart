import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/error_message.dart';
import '../../../core/responsive.dart';
import '../../../core/widgets/state_views.dart';
import '../../settings/presentation/account_info_actions.dart';
import '../../settings/presentation/settings_screen.dart';
import '../data/profile_photo_codec.dart';
import 'auth_providers.dart';
import 'login_screen.dart';
import 'profile_providers.dart';

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  Future<void> _editDisplayName(BuildContext context, WidgetRef ref, String currentName) async {
    final controller = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이름 수정'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: '이름')),
        actions: [
          TextButton(
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.of(context).pop();
            },
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.of(context).pop(value);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
    // 다이얼로그 닫힘 애니메이션이 끝나기 전에 컨트롤러를 dispose하면 크래시가 나서
    // (TextEditingController used after being disposed) 여기서는 수동 dispose를 하지 않는다.
    if (newName == null || newName.isEmpty || !context.mounted) return;

    try {
      await ref.read(authRepositoryProvider).updateDisplayName(newName);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(error))));
      }
    }
  }

  Future<void> _changePhoto(BuildContext context, WidgetRef ref, String uid) async {
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      final resized = await compute(resizeAndEncodeProfilePhoto, bytes);
      await ref.read(userProfileRepositoryProvider).setPhoto(uid, base64Encode(resized));
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(error))));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorStateView(message: friendlyErrorMessage(error)),
        data: (user) {
          if (user == null) {
            return Center(
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: const Text('로그인'),
              ),
            );
          }

          final profile = ref.watch(userProfileProvider).valueOrNull;
          final customPhoto = profile?.photoBase64;

          return ResponsiveCenter(
            maxWidth: 480,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Column(
                  children: [
                    Stack(
                      children: [
                        _ProfileAvatar(user: user, customPhotoBase64: customPhoto),
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: IconButton.filled(
                            icon: const Icon(Icons.camera_alt_outlined, size: 18),
                            onPressed: () => _changePhoto(context, ref, user.uid),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.displayName?.isNotEmpty == true ? user.displayName! : (user.email ?? '사용자'),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: () => _editDisplayName(context, ref, user.displayName ?? ''),
                        ),
                      ],
                    ),
                    if (user.email != null) Text(user.email!, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.cake_outlined),
                        title: const Text('생년월일'),
                        subtitle: Text(profile?.birthDate != null ? formatBirthDate(profile!.birthDate!) : '설정 안 함'),
                        onTap: () => pickBirthDate(context, ref, user.uid, profile?.birthDate),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.phone_outlined),
                        title: const Text('휴대폰번호'),
                        subtitle: Text(profile?.phoneNumber ?? '설정 안 함'),
                        onTap: () => editPhoneNumber(context, ref, user.uid, profile?.phoneNumber),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => ref.read(authRepositoryProvider).signOut(),
                  child: const Text('로그아웃'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.user, required this.customPhotoBase64});

  final User user;
  final String? customPhotoBase64;

  @override
  Widget build(BuildContext context) {
    const radius = 40.0;

    if (customPhotoBase64 != null) {
      return CircleAvatar(radius: radius, backgroundImage: MemoryImage(base64Decode(customPhotoBase64!)));
    }
    if (user.photoURL != null) {
      return CircleAvatar(radius: radius, backgroundImage: NetworkImage(user.photoURL!));
    }
    return CircleAvatar(radius: radius, child: const Icon(Icons.person, size: 32));
  }
}
