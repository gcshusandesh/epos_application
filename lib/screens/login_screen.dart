import 'package:epos_application/components/data.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:epos_application/screens/dashboard.dart';
import 'package:epos_application/screens/reset_password.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/buttons.dart';
import '../components/size_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const routeName = "loginScreen";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildTitleText(
            Provider.of<InfoProvider>(context, listen: false).restaurantName,
            Data.greyTextColor,
            width,
          ),
          SizedBox(height: height * 2),
          buildImage("assets/restaurant_image.png", 200, 300),
          SizedBox(height: height * 2),
          buildTitleText(
            "Log In",
            Data.greyTextColor,
            width,
          ),
          SizedBox(height: height * 2),
          buildBodyText(
            "Please enter your credentials to access the EPOS system.",
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
          SizedBox(height: height * 1),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTitleText(
                "Password",
                Data.lightGreyTextColor,
                width * 0.8,
              ),
              buildInputField("Password", height, width),
            ],
          ),
          SizedBox(height: height * 4),
          buildButton(
            Icons.person,
            "Log In",
            height,
            width,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Dashboard()),
              );
            },
          ),
          SizedBox(height: height * 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: value,
                activeColor: Data.iconsColor,
                side: WidgetStateBorderSide.resolveWith(
                  (states) => const BorderSide(
                      width: 1.0, color: Data.lightGreyTextColor),
                ),
                onChanged: (bool? changedValue) {
                  setState(() {
                    value = changedValue!;
                  });
                },
              ),
              const SizedBox(
                width: 2,
              ),
              buildSmallText(
                "Remember me",
                Data.lightGreyTextColor,
                width,
              ),
            ],
          ),
          SizedBox(height: height * 2),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ResetPassword()),
              );
            },
            child: buildSmallText(
              "Forgot your Password?",
              Data.iconsColor,
              width,
              selectable: false,
            ),
          ),
        ],
      ),
    );
  }
}
