import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

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
    required double width,
    bool initialSetup = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      !initialSetup
          ? iconButton(
              "assets/svg/arrow_back.svg",
              height,
              width,
              () {
                Navigator.pop(context);
              },
              context: context,
            )
          : SizedBox(
              width: width * 5,
            ),
      buildTitleText(text, Data.darkTextColor, width),
      SizedBox(
        width: width * 5,
      ),
    ],
  );
}

Row customTopSection(
    {required BuildContext context,
    required double height,
    required String text,
    required double width,
    required Function() onTap}) {
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
        context: context,
      ),
      buildTitleText(text, Data.darkTextColor, width),
      iconButton(
        "",
        height,
        width,
        onTap,
        isSvg: false,
        icon: Icons.refresh,
        context: context,
      ),
    ],
  );
}

Widget onLoading({required double width, required BuildContext context}) {
  return Stack(
    children: [
      const ModalBarrier(
        color: Colors.black54, // Semi-transparent black color
        dismissible: false, // Prevents dismissing overlay with taps
      ),
      Center(
        child: Container(
          height: width * 8,
          width: width * 8,
          padding: EdgeInsets.all(width * 2),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0, 0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
          ),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                Provider.of<InfoProvider>(context, listen: true)
                    .systemInfo
                    .primaryColor),
          ),
        ),
      ),
    ],
  );
}

Widget buildCupertinoSwitch(
    {required int index,
    required bool value,
    required Function(bool) onChanged,
    required BuildContext context}) {
  return Transform.scale(
    scale: 1.2,
    child: CupertinoSwitch(
      activeColor: Provider.of<InfoProvider>(context, listen: true)
          .systemInfo
          .primaryColor,
      trackColor: Data.greyTextColor,
      value: value,
      onChanged: onChanged,
    ),
  );
}

Widget tableTitle(String text, double width) {
  return Center(
      child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 5),
    child: buildBodyText(
      text,
      Data.lightGreyTextColor,
      width * 0.9,
      fontFamily: "RobotoMedium",
    ),
  ));
}

Widget tableItem(String text, double width, BuildContext context) {
  return Center(
      child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: buildSmallText(
      text,
      text == OrderStatus.preparing.name
          ? Provider.of<InfoProvider>(context, listen: true)
              .systemInfo
              .iconsColor
          : text == OrderStatus.ready.name
              ? Provider.of<InfoProvider>(context, listen: true)
                  .systemInfo
                  .primaryColor
              : text == OrderStatus.cancelled.name
                  ? Data.redColor
                  : text == OrderStatus.served.name
                      ? Data.greenColor
                      : Data.lightGreyTextColor,
      width * 1.2,
    ),
  ));
}
