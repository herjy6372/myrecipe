import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/error_message.dart';
import '../../../core/widgets/state_views.dart';
import 'auth_providers.dart';
import 'login_screen.dart';

class MyPageScreen extends ConsumerWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
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
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(radius: 32, child: Icon(Icons.person, size: 32)),
                const SizedBox(height: 12),
                Text(user.email ?? user.displayName ?? '사용자', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 20),
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
