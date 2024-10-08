import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/providers/auth_provider.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:flutter/material.dart';
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
  bool isLoading = false;
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

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        mainBody(context),
        isLoading
            ? onLoading(width: width, context: context)
            : const SizedBox(),
      ],
    );
  }

  Scaffold mainBody(BuildContext context) {
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
              buildImage(
                Provider.of<InfoProvider>(context, listen: false)
                    .restaurantInfo
                    .imageUrl!,
                isNetworkImage: true,
                height * 25,
                width * 30,
                context: context,
              ),
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
                  ? Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          buildDataBox(
                            title: "Current Password",
                            controller: currentPasswordController,
                            context: context,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Enter a valid password!';
                              }
                              if (value.length < 6) {
                                return 'Must be at least 6 characters!';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: height * 2),
                          buildDataBox(
                            title: "New Password",
                            controller: newPasswordController,
                            context: context,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Enter a valid password!';
                              }
                              if (value.length < 6) {
                                return 'Must be at least 6 characters!';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: height * 2),
                          buildDataBox(
                            title: "Confirm New Password",
                            controller: newPasswordConfirmationController,
                            context: context,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Enter a valid password!';
                              }
                              if (value.length < 6) {
                                return 'Must be at least 6 characters!';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    )
                  : Form(
                      key: _formKey,
                      child: buildDataBox(
                        title: "Email",
                        controller: emailController,
                        context: context,
                        validator: (value) {
                          if (value.isEmpty ||
                              !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(value)) {
                            return 'Enter a valid email!';
                          }
                          return null;
                        },
                      ),
                    ),
              SizedBox(height: height * 4),
              buildButton(
                Icons.password,
                widget.isChangePassword ? "Change Password" : "Reset Password",
                height,
                width,
                () async {
                  if (_formKey.currentState!.validate()) {
                    FocusScope.of(context).requestFocus(FocusNode());
                    if (widget.isChangePassword) {
                      changeLogic();
                    } else {
                      resetLogin();
                    }
                  }
                },
                context,
              ),
              SizedBox(height: height * 2),
            ],
          ),
        ),
      ),
    );
  }

  void resetLogin() async {
    final overlayContext = Overlay.of(context);
    setState(() {
      isLoading = true;
    });
    int passwordResetCode =
        await Provider.of<AuthProvider>(context, listen: false)
            .resetUserPassword(
      context: context,
      email: emailController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (passwordResetCode == 200) {
      // show success massage
      showTopSnackBar(
        overlayContext,
        const CustomSnackBar.success(
          message: "New password has been sent to your registered email.",
        ),
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } else if (passwordResetCode == 404) {
      // show failure massage
      showTopSnackBar(
        overlayContext,
        const CustomSnackBar.error(
          message: "Email user not registered.",
        ),
      );
    } else {
      // show failure massage
      showTopSnackBar(
        overlayContext,
        const CustomSnackBar.error(
          message: "Password Not Reset.",
        ),
      );
    }
  }

  void changeLogic() async {
    final overlayContext = Overlay.of(context);
    setState(() {
      isLoading = true;
    });
    int passwordChangeCode =
        await Provider.of<AuthProvider>(context, listen: false)
            .updateUserPassword(
      context: context,
      currentPassword: currentPasswordController.text,
      newPassword: newPasswordController.text,
      confirmNewPassword: newPasswordConfirmationController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (passwordChangeCode == 200) {
      // show success massage
      showTopSnackBar(
        overlayContext,
        const CustomSnackBar.success(
          message: "Password Updated Successfully",
        ),
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } else if (passwordChangeCode == 400) {
      // show same password massage
      showTopSnackBar(
        overlayContext,
        const CustomSnackBar.error(
          message: "New Password cannot be same as Old Password",
        ),
      );
    } else if (passwordChangeCode == 403) {
      // show same password massage
      showTopSnackBar(
        overlayContext,
        const CustomSnackBar.error(
          message: "Passwords do not match",
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
  }

  Column buildDataBox(
      {required BuildContext context,
      required String title,
      required TextEditingController controller,
      required validator}) {
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
        buildInputField(title, height, width, context, controller,
            validator: validator),
      ],
    );
  }
}
