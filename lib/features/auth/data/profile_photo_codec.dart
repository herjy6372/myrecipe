import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// 프로필 사진을 정사각형으로 잘라 작게 리사이즈하고 JPEG로 인코딩한다.
/// Firestore 문서 필드로 저장하기 위한 것이라 용량을 최대한 줄인다.
/// compute()로 별도 isolate에서 돌릴 수 있도록 top-level 함수로 둔다.
Uint8List resizeAndEncodeProfilePhoto(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw const FormatException('이미지를 처리할 수 없어요.');
  }

  final side = decoded.width < decoded.height ? decoded.width : decoded.height;
  final cropped = img.copyCrop(
    decoded,
    x: (decoded.width - side) ~/ 2,
    y: (decoded.height - side) ~/ 2,
    width: side,
    height: side,
  );
  final resized = img.copyResize(cropped, width: 256, height: 256);
  return Uint8List.fromList(img.encodeJpg(resized, quality: 80));
}
