import 'package:flutter/material.dart';

const double kTabletBreakpoint = 600;

bool isWideLayout(BuildContext context) => MediaQuery.sizeOf(context).width >= kTabletBreakpoint;

/// 태블릿 가로모드처럼 화면이 넓을 때, 읽기 좋은 폭으로 콘텐츠를 가운데 정렬한다.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({required this.child, this.maxWidth = 640, super.key});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (!isWideLayout(context)) return child;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
    );
  }
}
