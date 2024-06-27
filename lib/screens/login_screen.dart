import 'package:epos_application/components/data.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:epos_application/screens/dashboard.dart';
import 'package:epos_application/screens/reset_password.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTitleText(
              Provider.of<InfoProvider>(context, listen: false)
                  .restaurantInfo
                  .name,
              Data.greyTextColor,
              width,
            ),
            SizedBox(height: height),
            buildImage("assets/restaurant_image.png", height * 25, width * 30),
            buildTitleText(
              "Log In",
              Data.greyTextColor,
              width,
            ),
            buildBodyText(
              "Please enter your credentials to access the EPOS system.",
              Data.lightGreyTextColor,
              width,
            ),
            SizedBox(height: height),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTitleText(
                  "Email",
                  Data.lightGreyTextColor,
                  width * 0.7,
                ),
                buildInputField("Email", height, width, context),
              ],
            ),
            SizedBox(height: height),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTitleText(
                  "Password",
                  Data.lightGreyTextColor,
                  width * 0.7,
                ),
                buildInputField("Password", height, width, context),
              ],
            ),
            SizedBox(height: height * 2),
            buildButton(
              Icons.person,
              "Log In",
              height,
              width,
              () {
                // FocusScope.of(context).requestFocus(FocusNode());
                showTopSnackBar(
                  Overlay.of(context),
                  const CustomSnackBar.success(
                    message: "You have successfully logged in",
                  ),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Dashboard()),
                );
              },
              context,
            ),
            SizedBox(height: height),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: value,
                  activeColor: Provider.of<InfoProvider>(context, listen: true)
                      .systemInfo
                      .iconsColor,
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
            SizedBox(height: height),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ResetPassword()),
                );
              },
              child: buildSmallText(
                "Forgot your Password?",
                Provider.of<InfoProvider>(context, listen: true)
                    .systemInfo
                    .iconsColor,
                width,
                selectable: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
