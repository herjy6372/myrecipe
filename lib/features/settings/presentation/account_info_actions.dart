import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/error_message.dart';
import '../../auth/presentation/profile_providers.dart';
import 'kr_phone_formatter.dart';

/// 마이페이지와 설정 화면에서 똑같이 쓰는 생년월일/휴대폰번호 수정 로직.
Future<void> pickBirthDate(BuildContext context, WidgetRef ref, String uid, DateTime? current) async {
  final now = DateTime.now();
  final picked = await showDatePicker(
    context: context,
    initialDate: current ?? DateTime(now.year - 20),
    firstDate: DateTime(1900),
    lastDate: now,
  );
  if (picked == null) return;
  try {
    await ref.read(userProfileRepositoryProvider).setBirthDate(uid, picked);
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(error))));
    }
  }
}

Future<void> editPhoneNumber(BuildContext context, WidgetRef ref, String uid, String? current) async {
  final controller = TextEditingController(text: current == null ? '' : stripCountryCode(current));
  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('휴대폰번호'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        inputFormatters: [KrPhoneNumberFormatter()],
        decoration: const InputDecoration(labelText: '010-1234-5678'),
      ),
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
  // controller를 여기서 바로 dispose하면 다이얼로그가 닫히는 애니메이션이 끝나기 전에
  // TextField가 이미 dispose된 컨트롤러를 다시 그리려다 크래시가 난다(TextEditingController
  // used after being disposed → framework의 _dependents.isEmpty 단언 실패로 이어짐).
  // 짧게 쓰고 버리는 다이얼로그 전용 컨트롤러라 GC에 맡기고 수동 dispose는 하지 않는다.
  if (result == null || result.isEmpty || !context.mounted) return;

  try {
    await ref.read(userProfileRepositoryProvider).setPhoneNumber(uid, toDisplayPhoneNumber(result));
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(error))));
    }
  }
}

String formatBirthDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}.$month.$day';
}
