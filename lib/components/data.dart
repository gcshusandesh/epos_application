import 'package:flutter/material.dart';

class Data {
  static const appName = 'EPOS Application';
  static const primaryColor = Color(0xff063B9D);
  static const iconsColor = Color(0xff4071B6);
  static const greenColor = Color(0xff22C55E);
  static const redColor = Color(0xffC52222);
  static const lightGreyBodyColor = Color(0xffD9D9D9);
  static const darkTextColor = Color(0xff000000);
  static const greyTextColor = Color(0xff1F2937);
  static const lightGreyTextColor = Color(0xff4B5563);
}

Widget buildImage(
    String asset,
    double height,
    double width,
    {
      BoxFit fit = BoxFit.fill,
    }) {
    return SizedBox(
    height: height,
    width: width,
    child: Image.asset(" assets/splash.png", fit: fit,),);
}

Widget buildTitleText(
    String text,
    Color color,
    double width, {
      String fontFamily = "RobotoBold",
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
