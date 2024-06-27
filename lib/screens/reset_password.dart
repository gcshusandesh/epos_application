import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/data.dart';
import 'package:flutter/material.dart';

import '../components/size_config.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});
  static const routeName = "resetPassword";

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

  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    //to save memory
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
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
                  buildInputField(
                      "Email", height, width, context, passwordController),
                ],
              ),
              SizedBox(height: height * 4),
              buildButton(
                Icons.person,
                "Reset",
                height,
                width,
                () {},
                context,
              ),
              SizedBox(height: height * 2),
            ],
          ),
        ),
      ),
    );
  }
}
