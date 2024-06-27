import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});
  static const routeName = "settings";

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool init = true;
  late double height;
  late double width;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (init) {
      //initialize size config at the very beginning
      SizeConfig().init(context);
      height = SizeConfig.safeBlockVertical;
      width = SizeConfig.safeBlockHorizontal;
      init = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            topSection(
                context: context,
                height: height,
                text: "Settings",
                width: width),
            SizedBox(height: height * 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                leftSection(),
                line(),
                rightSection(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container line() {
    return Container(
      height: height * 80,
      width: 1,
      color: Colors.black,
    );
  }

  Container rightSection() {
    return Container(
      height: height * 80,
      width: width * 35,
      padding:
          EdgeInsets.symmetric(vertical: height * 2, horizontal: width * 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Data.lightGreyBodyColor50,
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
        children: [
          editSection("System Details", noEdit: true, () {}),
          Container(
            width: width * 31,
            padding: EdgeInsets.symmetric(
                vertical: height * 2, horizontal: width * 2),
            color: Data.lightGreyBodyColor,
            child: Column(
              children: [
                Container(
                  width: width * 30,
                  padding: EdgeInsets.symmetric(
                      vertical: height, horizontal: width * 2),
                  color: Colors.white,
                  child: fancyDataBox(
                    title: "Version",
                    data: "#1.00",
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: height * 2),
          editSection("System Settings", () {}),
        ],
      ),
    );
  }

  Row fancyDataBox({required String title, required String data}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        buildCustomText("Version", Data.lightGreyTextColor, width * 1.4,
            fontFamily: "RobotoMedium"),
        buildLine(),
        buildCustomText("#1.00", Data.lightGreyTextColor, width * 1.4,
            fontFamily: "RobotoMedium"),
      ],
    );
  }

  Container buildLine() {
    return Container(
      color: Data.lightGreyTextColor,
      width: 2,
      height: height * 4,
    );
  }

  Container leftSection() {
    return Container(
      height: height * 80,
      width: width * 35,
      padding:
          EdgeInsets.symmetric(vertical: height * 2, horizontal: width * 2),
      decoration: BoxDecoration(
        color: Data.lightGreyBodyColor50,
        borderRadius: BorderRadius.circular(10),
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
        children: [
          editSection("Restaurant's Details", () {}),
          SizedBox(height: height * 2),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildImage(
                      "assets/restaurant_image.png", height * 25, width * 31),
                  SizedBox(height: height * 2),
                  dataBox(
                      title: "Name",
                      data: Provider.of<InfoProvider>(context, listen: true)
                          .restaurantInfo
                          .name),
                  SizedBox(height: height),
                  dataBox(
                      title: "VAT/PAN Number",
                      data: Provider.of<InfoProvider>(context, listen: true)
                          .restaurantInfo
                          .vatNumber),
                  SizedBox(height: height),
                  dataBox(
                      title: "Address",
                      data: Provider.of<InfoProvider>(context, listen: true)
                          .restaurantInfo
                          .address),
                  SizedBox(height: height),
                  dataBox(
                      title: "Postcode",
                      data: Provider.of<InfoProvider>(context, listen: true)
                          .restaurantInfo
                          .postcode),
                  SizedBox(height: height),
                  dataBox(
                      title: "Country of Operation",
                      data: Provider.of<InfoProvider>(context, listen: true)
                          .restaurantInfo
                          .countryOfOperation),
                  SizedBox(height: height),
                  dataBox(
                      title: "Logo",
                      isImage: true,
                      data: Provider.of<InfoProvider>(context, listen: true)
                          .restaurantInfo
                          .logoUrl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row editSection(String title, Function() onPressed, {bool noEdit = false}) {
    return Row(
      mainAxisAlignment:
          noEdit ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
      children: noEdit
          ? [
              buildBodyText(title, Data.lightGreyTextColor, width,
                  fontFamily: "RobotoMedium"),
            ]
          : [
              Opacity(
                opacity: 0,
                child: iconButton(
                  "assets/svg/edit.svg",
                  height,
                  width,
                  () {
                    //do nothing
                  },
                  context: context,
                ),
              ),
              buildBodyText(title, Data.lightGreyTextColor, width,
                  fontFamily: "RobotoMedium"),
              iconButton(
                "assets/svg/edit.svg",
                height,
                width,
                onPressed,
                context: context,
              ),
            ],
    );
  }

  Container dataBox({
    required String title,
    required String data,
    bool isImage = false,
  }) {
    return Container(
      width: width * 31,
      padding: EdgeInsets.symmetric(vertical: height, horizontal: width * 2),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildCustomText(title, Data.lightGreyTextColor, width * 1.4,
              fontFamily: "RobotoMedium"),
          isImage
              ? buildImage(data, width * 10, width * 10)
              : buildCustomText(
                  data,
                  Data.lightGreyTextColor,
                  width,
                ),
        ],
      ),
    );
  }
}
