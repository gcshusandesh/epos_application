import 'package:epos_application/components/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget dashboardItem(
  String asset,
  String text,
  double height,
  double width,
) {
  return Container(
    height: width * 20,
    width: width * 20,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Data.iconsColor, // Outline color
        width: 0.5, // Outline width
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.25), // Shadow color
          spreadRadius: 0, // How much the shadow spreads
          blurRadius: 4, // How much the shadow blurs
          offset: const Offset(0, 5), // The offset of the shadow
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          asset,
          height: 50,
          width: 50,
          fit: BoxFit.scaleDown,
        ),
        buildCustomText(
          text,
          Data.greyTextColor,
          width * 1.2,
          fontFamily: "RobotoMedium",
        ),
      ],
    ),
  );
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
