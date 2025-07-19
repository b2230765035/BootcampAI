import 'package:bootcamp175/config/material/colors/main_colors.dart';
import 'package:bootcamp175/config/variables/doubles/main_doubles.dart';
import 'package:flutter/material.dart';

class CustomIconTheme {
  ///Default size for Icons is 48.0 and default color is MainColors.primaryTextColor(#FFFFFF)
  static IconThemeData iconThemeData = IconThemeData(
    size: IconSizes.iconSizeM,
    color: MainColors.primaryTextColor,
  );
  static IconThemeData navBarSelectedItemTheme = IconThemeData(
    color: MainColors.primaryTextColor,
  );
  static IconThemeData navBarunSelectedItemTheme = IconThemeData(
    color: MainColors.secondaryTextColor,
  );
}
