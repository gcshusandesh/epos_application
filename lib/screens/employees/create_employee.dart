import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class CreateEmployee extends StatefulWidget {
  const CreateEmployee({super.key});
  static const routeName = "makeEmployee";

  @override
  State<CreateEmployee> createState() => _CreateEmployeeState();
}

class _CreateEmployeeState extends State<CreateEmployee> {
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
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            SizedBox(height: height * 2),
            Center(
              child: Container(
                height: height * 82,
                width: width * 35,
                padding: EdgeInsets.symmetric(
                    vertical: height * 2, horizontal: width * 2),
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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      buildTitleText(
                          "Create Employee", Data.darkTextColor, width * 0.8),
                      SizedBox(height: height),
                      Column(
                        children: [
                          Container(
                            width: width * 15,
                            height: width * 15,
                            padding: EdgeInsets.all(width * 3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Data.lightGreyBodyColor,
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                "assets/svg/profile_icon.svg",
                                colorFilter: ColorFilter.mode(
                                    Provider.of<InfoProvider>(context,
                                            listen: true)
                                        .systemInfo
                                        .iconsColor,
                                    BlendMode.srcIn),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          SizedBox(height: height),
                          buildInputField("Full Name", height, width, context),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container dataBox({
    required String title,
    required String hintText,
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
          // isImage
          //     ? buildImage(data, width * 10, width * 10)
          //     : buildCustomText(
          //         data,
          //         Data.lightGreyTextColor,
          //         width,
          //       ),
        ],
      ),
    );
  }
}
