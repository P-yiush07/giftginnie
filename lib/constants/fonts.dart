import 'package:flutter/material.dart';

abstract class AppFonts {
  static const String gilroy = 'GilroyBold';

  static const String gilroyMedium = 'GilroyMedium';

  static const TextStyle heading1 = TextStyle(
    fontFamily: gilroy,
  );

  static const TextStyle paragraph = TextStyle(
    fontFamily: gilroyMedium,
  );
}
