import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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
                    data:
                        "#${Provider.of<InfoProvider>(context, listen: true).systemInfo.versionNumber}",
                  ),
                ),
                SizedBox(height: height),
                Container(
                  width: width * 30,
                  padding: EdgeInsets.symmetric(
                      vertical: height, horizontal: width * 2),
                  color: Colors.white,
                  child: fancyDataBox(
                    title: "Language",
                    data: Provider.of<InfoProvider>(context, listen: true)
                        .systemInfo
                        .language,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: height * 2),
          editSection("System Settings", () {}),
          SizedBox(height: height * 2),
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
                    title: "Primary Color",
                    hasColor: true,
                    color: Provider.of<InfoProvider>(context, listen: true)
                        .systemInfo
                        .primaryColor,
                  ),
                ),
                SizedBox(height: height),
                Container(
                  width: width * 30,
                  padding: EdgeInsets.symmetric(
                      vertical: height, horizontal: width * 2),
                  color: Colors.white,
                  child: fancyDataBox(
                    title: "Icons Color",
                    hasColor: true,
                    color: Provider.of<InfoProvider>(context, listen: true)
                        .systemInfo
                        .iconsColor,
                  ),
                ),
                SizedBox(height: height),
                Container(
                  width: width * 30,
                  padding: EdgeInsets.symmetric(
                      vertical: height, horizontal: width * 2),
                  color: Colors.white,
                  child: fancyDataBox(
                    title: "Currency",
                    data: Provider.of<InfoProvider>(context, listen: true)
                        .systemInfo
                        .currencySymbol,
                  ),
                ),
                SizedBox(height: height * 2),
                buildButton(
                  Icons.restart_alt_sharp,
                  "Reset Default Settings",
                  height,
                  width,
                  () {
                    //reset Default values
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert();
                      },
                    );
                  },
                  context,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // set up the AlertDialog
  Widget alert() {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("Reset to Default Settings"),
      content:
          const Text("Would you like to reset the system setting to default?"),
      actions: [
        textButton(
          text: "Yes",
          height: height,
          width: width,
          textColor: Data.greenColor,
          buttonColor: Data.greenColor,
          onTap: () {
            // reset to default
            Provider.of<InfoProvider>(context, listen: false)
                .resetDefaultSystemSettings();
            // pop dialog box
            Navigator.pop(context);
            showTopSnackBar(
              Overlay.of(context),
              const CustomSnackBar.success(
                message:
                    "System has been reset to default settings successfully",
              ),
            );
          },
        ),
        SizedBox(height: height * 2),
        textButton(
          text: "No",
          height: height,
          width: width,
          textColor: Data.redColor,
          buttonColor: Data.redColor,
          onTap: () {
            // close dialog box
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Row fancyDataBox({
    required String title,
    String data = "",
    bool hasColor = false,
    Color color = Colors.black,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: width * 10,
              child: buildCustomText(
                  title, Data.lightGreyTextColor, width * 1.4,
                  fontFamily: "RobotoMedium"),
            ),
            SizedBox(width: width * 2),
            buildLine(),
          ],
        ),
        hasColor
            ? Container(
                width: width * 2.5,
                height: width * 2.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              )
            : buildCustomText(data, Data.lightGreyTextColor, width * 1.4,
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
