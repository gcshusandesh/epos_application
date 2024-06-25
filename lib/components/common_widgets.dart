import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

Future<dynamic> animatedNavigatorPush({
  required BuildContext context,
  required screen,
  PageTransitionType pageTransitionType = PageTransitionType.rightToLeft,
  Duration duration = const Duration(milliseconds: 300),
}) {
  return Navigator.push(
    context,
    PageTransition(
      type: pageTransitionType,
      child: screen,
      duration: duration,
    ),
  );
}

Future<dynamic> animatedNavigatorPushNamed({
  required BuildContext context,
  required Widget screen,
  PageTransitionType pageTransitionType = PageTransitionType.rightToLeft,
  Duration duration = const Duration(milliseconds: 300),
}) {
  return Navigator.push(
    context,
    PageTransition(
      type: pageTransitionType,
      child: screen,
      duration: duration,
    ),
  );
}

Row topSection(
    {required BuildContext context,
    required double height,
    required String text,
    required double width}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      iconButton(
        "assets/svg/arrow_back.svg",
        height,
        width,
        () {
          Navigator.pop(context);
        },
      ),
      buildTitleText(text, Data.darkTextColor, width),
      SizedBox(
        width: width * 5,
      ),
    ],
  );
}

Widget onLoading({required double width}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Material(
      color: Colors.white,
      child: Container(
        height: width * 32,
        width: width * 32,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0, 0), //(x,y)
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: width * 2,
            ),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Data.primaryColor),
            ),
            SizedBox(
              height: width * 4,
            ),
            buildCustomText("Loading...", Colors.black, width * 3.5),
          ],
        ),
      ),
    ),
  );
}

Widget buildCupertinoSwitch(
    {required int index,
    required bool value,
    required Function(bool) onChanged}) {
  return Transform.scale(
    scale: 1.5,
    child: CupertinoSwitch(
      activeColor: Data.primaryColor,
      trackColor: Data.greyTextColor,
      value: value,
      onChanged: onChanged,
    ),
  );
}

Widget tableTitle(String text, double width) {
  return Center(
      child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 15.0),
    child: buildBodyText(
      text,
      Data.lightGreyTextColor,
      width,
      fontFamily: "RobotoMedium",
    ),
  ));
}

Widget tableItem(String text, double width) {
  return Center(
      child: buildSmallText(
    text,
    Data.lightGreyTextColor,
    width,
  ));
}
