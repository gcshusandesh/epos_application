import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../components/size_config.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key, this.isChangePassword = false});
  static const routeName = "resetPassword";
  final bool isChangePassword;

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

  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController newPasswordConfirmationController =
      TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    //to save memory
    currentPasswordController.dispose();
    newPasswordController.dispose();
    newPasswordConfirmationController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      useDefaultLoading: false,
      overlayWidgetBuilder: (_) {
        //ignored progress for the moment
        return Center(
          child: onLoading(width: width, context: context),
        );
      },
      child: Scaffold(
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
                  widget.isChangePassword
                      ? "Please enter the following details to change your password."
                      : "Please enter the following details to reset your password.",
                  Data.lightGreyTextColor,
                  width,
                ),
                SizedBox(height: height * 2),
                widget.isChangePassword
                    ? Column(
                        children: [
                          buildDataBox(
                              title: "Current Password",
                              controller: currentPasswordController,
                              context: context),
                          SizedBox(height: height * 2),
                          buildDataBox(
                              title: "New Password",
                              controller: newPasswordController,
                              context: context),
                          SizedBox(height: height * 2),
                          buildDataBox(
                              title: "Confirm New Password",
                              controller: newPasswordConfirmationController,
                              context: context),
                        ],
                      )
                    : buildDataBox(
                        title: "Email",
                        controller: newPasswordConfirmationController,
                        context: context),
                SizedBox(height: height * 4),
                buildButton(
                  Icons.password,
                  widget.isChangePassword
                      ? "Change Password"
                      : "Reset Password",
                  height,
                  width,
                  () async {
                    final loaderOverlay = context.loaderOverlay;
                    final overlayContext = Overlay.of(context);
                    loaderOverlay.show();

                    int passwordChangeCode =
                        await Provider.of<AuthProvider>(context, listen: false)
                            .updateUserPassword(
                                context: context,
                                currentPassword: currentPasswordController.text,
                                newPassword: newPasswordController.text);

                    loaderOverlay.hide();
                    if (passwordChangeCode == 200) {
                      // show success massage
                      showTopSnackBar(
                        overlayContext,
                        const CustomSnackBar.success(
                          message: "Password Updated Successfully",
                        ),
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    } else if (passwordChangeCode == 400) {
                      // show same password massage
                      showTopSnackBar(
                        overlayContext,
                        const CustomSnackBar.info(
                          message:
                              "New password cannot be same as old password",
                        ),
                      );
                    } else {
                      // show failure massage
                      showTopSnackBar(
                        overlayContext,
                        const CustomSnackBar.error(
                          message: "Password Not Updated",
                        ),
                      );
                    }
                  },
                  context,
                ),
                SizedBox(height: height * 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column buildDataBox(
      {required BuildContext context,
      required String title,
      required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: width * 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              buildBodyText(
                title,
                Data.lightGreyTextColor,
                width * 0.8,
              ),
              buildSmallText(
                "*",
                Data.redColor,
                width,
              ),
            ],
          ),
        ),
        buildInputField(title, height, width, context, controller),
      ],
    );
  }
}
