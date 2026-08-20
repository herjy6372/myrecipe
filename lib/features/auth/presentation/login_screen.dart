import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/error_message.dart';
import '../../../core/responsive.dart';
import '../../settings/presentation/static_text_screen.dart';
import 'auth_error_message.dart';
import 'auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _run(Future<bool> Function() action) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final success = await action();
      if (success && mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = friendlyAuthErrorMessage(e));
    } catch (e) {
      setState(() => _errorMessage = friendlyErrorMessage(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authRepository = ref.read(authRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ResponsiveCenter(
            maxWidth: 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : () => _run(authRepository.signInWithGoogle),
                  icon: const Icon(Icons.g_mobiledata),
                  label: const Text('Google로 계속하기'),
                ),
                if (_isLoading) ...[
                  const SizedBox(height: 20),
                  const Center(child: CircularProgressIndicator()),
                ],
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const StaticTextScreen(title: '이용약관', content: termsOfServiceText),
                        ),
                      ),
                      child: const Text('이용수칙'),
                    ),
                    const Text('·'),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const StaticTextScreen(title: '개인정보 처리방침', content: privacyPolicyText),
                        ),
                      ),
                      child: const Text('개인정보 처리방침'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
