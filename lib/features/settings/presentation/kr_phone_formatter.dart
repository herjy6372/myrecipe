import 'package:flutter/services.dart';

/// 숫자만 입력받아 010-1234-5678 형태로 자동으로 하이픈을 넣어준다.
class KrPhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;

    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      if (i == 3 || i == 7) buffer.write('-');
      buffer.write(limited[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}

/// 저장/표시용으로 010-1234-5678 형태에 국가번호를 붙인다: +82-010-1234-5678
String toDisplayPhoneNumber(String localFormatted) {
  if (localFormatted.isEmpty) return localFormatted;
  return '+82-$localFormatted';
}

/// +82-010-1234-5678 형태에서 국가번호를 떼고 편집용 텍스트로 되돌린다.
String stripCountryCode(String displayNumber) {
  return displayNumber.replaceFirst('+82-', '');
}
