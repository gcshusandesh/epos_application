import 'package:epos_application/components/data.dart';
import 'package:flutter/material.dart';

import '../components/size_config.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});
  static const routeName = "loginScreen";

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  bool value = false;

  bool init = true;
  late double height;
  late double width;
  @override
  void didChangeDependencies() {
    if (init) {
      //initialize size config at the very beginning
      SizeConfig().init(context);
      height = SizeConfig.safeBlockVertical;
      width = SizeConfig.safeBlockHorizontal;
      super.didChangeDependencies();
      init = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: width * 2),
              iconButton(
                "assets/profile_icon.svg",
                height,
                width,
                () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          buildImage("assets/restaurant_image.png", 200, 300),
          SizedBox(height: height * 2),
          buildTitleText(
            "Reset Password",
            Data.greyTextColor,
            width,
          ),
          SizedBox(height: height * 2),
          buildBodyText(
            "Please enter your email to reset your password.",
            Data.lightGreyTextColor,
            width,
          ),
          SizedBox(height: height * 2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTitleText(
                "Email",
                Data.lightGreyTextColor,
                width * 0.8,
              ),
              buildInputField("Email", height, width),
            ],
          ),
          SizedBox(height: height * 4),
          buildButton(
            Icons.person,
            "Log In",
            height,
            width,
            () {},
          ),
          SizedBox(height: height * 2),
        ],
      ),
    );
  }
}
