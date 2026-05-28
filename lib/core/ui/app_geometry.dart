import 'package:flutter/material.dart';

class AppGeometry {
  AppGeometry._();

  // Radius
  static const double radiusXs = 8;
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusBubble = 18;

  // Heights
  static const double capsuleHeight = 44;
  static const double inputHeight = 52;

  // Insets
  static const double insetXs = 4;
  static const double insetSm = 8;
  static const double insetMd = 12;
  static const double insetLg = 16;

  // Shared Shapes
  static const BorderRadius capsuleRadius = BorderRadius.all(
    Radius.circular(radiusSm),
  );

  static const BorderRadius carrierRadius = BorderRadius.all(
    Radius.circular(radiusMd),
  );

  static const BorderRadius dialogRadius = BorderRadius.all(
    Radius.circular(radiusLg),
  );

  static const BorderRadius bubbleRadius = BorderRadius.all(
    Radius.circular(radiusBubble),
  );
}
