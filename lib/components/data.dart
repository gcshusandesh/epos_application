import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

Widget buildButton(
  IconData icon,
  String text,
  double height,
  double width,
  Function() onTap,
) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: height * 6,
      width: width * 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Data.primaryColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: width * 2,
          ),
          SizedBox(width: width * 2),
          buildCustomText(text, Colors.white, width * 1.5),
        ],
      ),
    ),
  );
}

Widget iconButton(
  String svg,
  double height,
  double width,
  Function() onTap, {
  bool isSvg = true,
  IconData icon = Icons.arrow_back,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: height * 6,
      width: width * 10,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Data.iconsColor, // Outline color
          width: 0.5, // Outline width
        ),
        borderRadius: BorderRadius.circular(6.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25), // Shadow color
            spreadRadius: 0, // How much the shadow spreads
            blurRadius: 4, // How much the shadow blurs
            offset: const Offset(0, 5), // The offset of the shadow
          ),
        ],
      ),
      child: isSvg
          ? SvgPicture.asset(
              svg,
              height: width,
              width: width,
              fit: BoxFit.scaleDown,
            )
          : Icon(
              icon,
              color: Data.iconsColor,
              size: width * 2,
            ),
    ),
  );
}

Widget buildInputField(
  String hintText,
  double height,
  double width,
) {
  return Container(
    height: height * 6,
    width: width * 40,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5.0),
    ),
    child: TextField(
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Data.primaryColor, // Custom focused border color
            width: 2.0, // Custom focused border width (optional)
          ),
        ),
        hintText: hintText,
      ),
    ),
  );
}

Widget buildImage(
  String asset,
  double height,
  double width, {
  BoxFit fit = BoxFit.fill,
}) {
  return SizedBox(
    height: height,
    width: width,
    child: Image.asset(
      asset,
      fit: fit,
    ),
  );
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
