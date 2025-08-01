import 'package:bootcamp175/config/material/colors/main_colors.dart';
import 'package:bootcamp175/config/variables/doubles/main_doubles.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';

class MainIcons {
  static Icon logoutIcon = Icon(
    CommunityMaterialIcons.logout,
    color: MainColors.accentColor,
    size: IconSizes.iconSizeS,
  );
  static Icon rightArrow = Icon(
    CommunityMaterialIcons.chevron_right,
    color: MainColors.secondaryTextColor,
    size: IconSizes.iconSizeXS,
  );
  static Icon leftArrow = Icon(
    CommunityMaterialIcons.arrow_left_thin_circle_outline,
    color: MainColors.secondaryTextColor,
  );

  static Icon profileIcon1 = const Icon(CommunityMaterialIcons.account_circle);
  static Icon profileIcon2 = Icon(
    CommunityMaterialIcons.account_box,
    size: IconSizes.iconSizeS,
    color: MainColors.primaryTextColor,
  );
  static Icon profileIcon3 = Icon(
    CommunityMaterialIcons.account_circle,
    size: IconSizes.iconSizeL,
    color: MainColors.primaryTextColor,
  );
  static Icon profileIcon4 = Icon(CommunityMaterialIcons.account_circle);

  static Icon settingsIcon = Icon(
    CommunityMaterialIcons.cog_outline,
    color: MainColors.secondaryTextColor,
  );
  static Icon mainIcon = Icon(CommunityMaterialIcons.account_group);
  static Icon questionIcon = Icon(CommunityMaterialIcons.chat_question);
  static Icon bellIcon = Icon(
    CommunityMaterialIcons.bell_alert,
    color: MainColors.accentColor,
  );
  static Icon bellIconNoNotification = Icon(
    CommunityMaterialIcons.bell_check,
    color: Colors.green,
  );
  static Icon publicRoomIcon = Icon(
    Icons.question_mark,
    color: Colors.green,
    size: IconSizes.iconSizeXS,
  );
}
