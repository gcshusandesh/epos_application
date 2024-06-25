import 'package:epos_application/components/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Row backButton(BuildContext context, double width, double height) {
  return Row(
    children: [
      SizedBox(width: width * 2),
      iconButton(
        "assets/arrow_back.svg",
        height,
        width,
        () {
          Navigator.pop(context);
        },
      ),
    ],
  );
}

Widget dashboardItem(
  String asset,
  String text,
  double height,
  double width,
  Function() onTap,
) {
  return InkWell(
    onTap: onTap,
    child: Container(
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
          SizedBox(
            height: width * 13, // Define the size of the SVG image
            width: width * 13,
            child: SvgPicture.asset(
              asset,
            ),
          ),
          const Flexible(child: SizedBox(height: 10)),
          buildCustomText(
            text,
            Data.greyTextColor,
            width * 1.5,
            fontFamily: "RobotoMedium",
          ),
        ],
      ),
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
          buildCustomText(
            text,
            Colors.white,
            width * 1.5,
            selectable: false,
          ),
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
      height: height * 5,
      width: width * 5,
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
      child: Center(
        child: isSvg
            ? SvgPicture.asset(
                svg,
                height: width * 2,
                width: width * 2,
                fit: BoxFit.contain,
              )
            : Icon(
                icon,
                color: Data.iconsColor,
                size: width * 2,
              ),
      ),
    ),
  );
}

Widget textButton({
  required String text,
  required double height,
  required double width,
  required Color textColor,
  required Color buttonColor,
  required Function() onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: height * 5,
      width: width * 2,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: buttonColor, // Outline color
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
      child: Center(
        child: buildSmallText(text, textColor, width),
      ),
    ),
  );
}
