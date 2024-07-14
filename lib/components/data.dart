import 'dart:io';

import 'package:epos_application/providers/info_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Data {
  static const appName = 'EPOS Application';
  static const baseUrl = "https://restaurantepos.xyz";
  static const greenColor = Color(0xff22C55E);
  static const redColor = Color(0xffC52222);
  static const lightGreyBodyColor50 = Color(0xffECECEC);
  static const lightGreyBodyColor = Color(0xffD9D9D9);
  static const darkTextColor = Color(0xff000000);
  static const greyTextColor = Color(0xff1F2937);
  static const lightGreyTextColor = Color(0xff4B5563);
}

Widget buildInputField(String hintText, double height, double width,
    BuildContext context, TextEditingController controller,
    {Function? validator}) {
  return Container(
    height: height * 6,
    width: width * 40,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5.0),
    ),
    child: TextFormField(
      cursorColor: Provider.of<InfoProvider>(context, listen: true)
          .systemInfo
          .primaryColor,
      controller: controller,
      validator: (value) {
        return validator!(value);
      },
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Data.lightGreyBodyColor, // Custom focused border color
            width: 1, // Custom focused border width (optional)
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Provider.of<InfoProvider>(context, listen: true)
                .systemInfo
                .primaryColor, // Custom focused border color
            width: 2.0, // Custom focused border width (optional)
          ),
        ),
        hintText: hintText,
      ),
    ),
  );
}

Widget buildPasswordField(
  String hintText,
  double height,
  double width,
  BuildContext context,
  TextEditingController controller, {
  required Function() onPressed,
  required bool obscureText,
  Function? validator,
}) {
  return Container(
    height: height * 6,
    width: width * 40,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5.0),
    ),
    child: TextFormField(
      cursorColor: Provider.of<InfoProvider>(context, listen: true)
          .systemInfo
          .primaryColor,
      controller: controller,
      obscureText: obscureText,
      validator: (value) {
        return validator!(value);
      },
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Data.lightGreyBodyColor, // Custom focused border color
            width: 1, // Custom focused border width (optional)
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Provider.of<InfoProvider>(context, listen: true)
                .systemInfo
                .primaryColor, // Custom focused border color
            width: 2.0, // Custom focused border width (optional)
          ),
        ),
        hintText: hintText,
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Provider.of<InfoProvider>(context, listen: true)
                .systemInfo
                .iconsColor,
          ),
          onPressed: onPressed,
        ),
      ),
    ),
  );
}

Widget buildImage(
  String path,
  double height,
  double width, {
  bool networkImage = false,
  bool fileImage = false,
  BoxFit fit = BoxFit.fill,
}) {
  return SizedBox(
    height: height,
    width: width,
    child: networkImage
        ? Image.network(
            path,
            fit: fit,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          )
        : fileImage
            ? Image.file(
                File(path),
                fit: fit,
              )
            : Image.asset(
                path,
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
  bool selectable = false,
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
  bool selectable = false,
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
  bool selectable = false,
}) {
  TextStyle style = TextStyle(
      fontSize: width * 1.25,
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
  bool selectable = false,
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
