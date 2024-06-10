import 'package:flutter/material.dart';

class Data {
  static const appName = 'Personal Portfolio Website';
  static const primaryBlue = Color(0xff062041);
  static const primaryDarkBlue = Color(0xff020B16);
  static const primaryRed = Color(0xffFF4C5A);
  static const primaryTextColor = Color(0xff000000);
}


Widget buildTitleText(
    String text,
    Color color,
    double width, {
      String fontFamily = "RobotoRegular",
      FontWeight fontWeight = FontWeight.normal,
      bool selectable = true,
    }) {
  TextStyle style = TextStyle(
      fontSize: width * 3,
      color: color,
      fontFamily: fontFamily,
      fontWeight: fontWeight);
  return selectable
      ? SelectableText(
    text,
    style: style,
  )
      : Text(
    text,
    style: style,
  );
}

Widget buildBodyText(
    String text,
    Color color,
    double width, {
      String fontFamily = "RobotoRegular",
      FontWeight fontWeight = FontWeight.normal,
      bool selectable = true,
    }) {
  TextStyle style = TextStyle(
      fontSize: width * 2,
      color: color,
      fontFamily: fontFamily,
      fontWeight: fontWeight);
  return selectable
      ? SelectableText(
    text,
    style: style,
  )
      : Text(
    text,
    style: style,
  );
}

Widget buildSmallText(
    String text,
    Color color,
    double width, {
      String fontFamily = "RobotoRegular",
      FontWeight fontWeight = FontWeight.normal,
      bool selectable = true,
    }) {
  TextStyle style = TextStyle(
      fontSize: width * 1,
      color: color,
      fontFamily: fontFamily,
      fontWeight: fontWeight);
  return selectable
      ? SelectableText(
    text,
    style: style,
  )
      : Text(
    text,
    style: style,
  );
}

Widget buildCustomText(
    String text,
    Color color,
    double width, {
      FontWeight fontWeight = FontWeight.normal,
      String fontFamily = "RobotoRegular",
      double? height,
      TextAlign? textAlign,
      bool selectable = true,
      TextDecoration? decoration,
      double letterSpacing = 0,
    }) {
  TextStyle style = TextStyle(
    decoration: decoration,
    fontSize: width,
    color: color,
    fontFamily: fontFamily,
    fontWeight: fontWeight,
    height: height,
    letterSpacing: letterSpacing,
  );
  return selectable
      ? SelectableText(
    text,
    textAlign: textAlign,
    style: style,
  )
      : Text(
    text,
    textAlign: textAlign,
    style: style,
  );
}
