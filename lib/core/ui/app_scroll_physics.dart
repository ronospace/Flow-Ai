import 'package:flutter/widgets.dart';

abstract final class AppScrollPhysics {
  static const ScrollPhysics spring = BouncingScrollPhysics(
    parent: AlwaysScrollableScrollPhysics(),
  );
}
