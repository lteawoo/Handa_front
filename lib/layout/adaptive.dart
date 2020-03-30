import 'package:flutter/material.dart';

enum DisplayType {
  desktop,
  mobile,
}

const _desktopPortraitBreakPoint = 700.0;
const _desktopLandscapeBreakPoint = 1000.0;

DisplayType displayTypeOf(BuildContext context) {
  final orientation = MediaQuery.of(context).orientation;
  final width = MediaQuery.of(context).size.width;

  if((orientation == Orientation.landscape &&
      width > _desktopLandscapeBreakPoint) ||
     (orientation == Orientation.portrait &&
      width > _desktopPortraitBreakPoint)) {
    return DisplayType.desktop;
  } else {
    return DisplayType.mobile;
  }
}

bool isDisplayDesktop(BuildContext context) {
  return displayTypeOf(context) == DisplayType.desktop;
}

bool isDisplaySmallDesktop(BuildContext context) {
  return isDisplayDesktop(context) && MediaQuery.of(context).size.width < _desktopLandscapeBreakPoint;
}