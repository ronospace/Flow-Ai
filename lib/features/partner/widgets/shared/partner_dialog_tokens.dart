import 'package:flutter/material.dart';

class PartnerDialogTokens {
  static const double maxWidth = 440;
  static const double radiusOuter = 28;
  static const double radiusInner = 20;
  static const double radiusSmall = 16;

  static const EdgeInsets shellPadding = EdgeInsets.all(14);
  static const EdgeInsets contentPadding = EdgeInsets.all(18);
  static const EdgeInsets sectionGap = EdgeInsets.symmetric(vertical: 10);

  static const List<Color> accent = [
    Color(0xFFFF5FA2),
    Color(0xFFA855F7),
  ];

  static const List<BoxShadow> shadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];
}
