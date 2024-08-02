import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/providers/auth_provider.dart';
import 'package:epos_application/providers/extra_provider.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:epos_application/screens/dashboard.dart';
import 'package:epos_application/screens/employees/create_employee.dart';
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
  bool isLoading = false;
  bool initialCheck = false;

  bool init = true;
  late double height;
  late double width;

  @override
  initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });
    await Provider.of<InfoProvider>(context, listen: false).getSettings(
      context: context,
    );
    initialCheck = true;
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (init) {
      //initialize size config at the very beginning
      SizeConfig().init(context);
      height = SizeConfig.safeBlockVertical;
      width = SizeConfig.safeBlockHorizontal;
      init = false;
    }
  }

  TextEditingController idController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    //to save memory
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool obscureText = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (initialCheck &&
        !Provider.of<InfoProvider>(context, listen: false)
            .restaurantInfo
            .hasAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateEmployee(
              isInitialSetup: true,
            ),
          ),
          (Route<dynamic> route) =>
              false, // This predicate removes all previous routes
        );
      });
    }
    return Stack(
      children: [
        mainBody(context),
        isLoading
            ? onLoading(width: width, context: context)
            : const SizedBox(),
      ],
    );
  }

  Widget mainBody(BuildContext context) {
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
                      .name ??
                  "EPOS System",
              Data.greyTextColor,
              width,
            ),
            SizedBox(height: height),
            Provider.of<InfoProvider>(context, listen: false)
                        .restaurantInfo
                        .imageUrl ==
                    null
                ? SizedBox(
                    height: height * 25,
                    width: width * 30,
                    child: buildImage(
                      "assets/restaurant_image.png",
                      height * 25,
                      width * 30,
                      context: context,
                    ))
                : buildImage(
                    Provider.of<InfoProvider>(context, listen: false)
                        .restaurantInfo
                        .imageUrl!,
                    isNetworkImage: true,
                    height * 25,
                    width * 30,
                    context: context,
                  ),
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
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTitleText(
                    "Username/Email",
                    Data.lightGreyTextColor,
                    width * 0.7,
                  ),
                  buildInputField(
                      "Username/Email", height, width, context, idController,
                      validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter a valid username/email!';
                    }
                    return null;
                  }),
                  buildTitleText(
                    "Password",
                    Data.lightGreyTextColor,
                    width * 0.7,
                  ),
                  buildPasswordField(
                    "Password",
                    height,
                    width,
                    context,
                    passwordController,
                    obscureText:
                        Provider.of<ExtraProvider>(context, listen: true)
                            .obscureText,
                    onPressed: () {
                      Provider.of<ExtraProvider>(context, listen: false)
                          .changeObscureText();
                    },
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
            ),
            SizedBox(height: height),
            buildButton(
              Icons.person,
              "Log In",
              height,
              width,
              () async {
                if (_formKey.currentState!.validate()) {
                  // if validation is successful, the code within this block will be executed
                  // Call Login API
                  FocusScope.of(context).requestFocus(FocusNode());
                  loginLogin();
                }
              },
              context,
            ),
            SizedBox(height: height),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: Provider.of<AuthProvider>(context, listen: true)
                      .stayLoggedIn,
                  activeColor: Provider.of<InfoProvider>(context, listen: true)
                      .systemInfo
                      .iconsColor,
                  side: WidgetStateBorderSide.resolveWith(
                    (states) => const BorderSide(
                        width: 1.0, color: Data.lightGreyTextColor),
                  ),
                  onChanged: (bool? changedValue) {
                    Provider.of<AuthProvider>(context, listen: false)
                        .changeStayLoggedInStatus(stayLoggedIn: changedValue!);
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

  void loginLogin() async {
    setState(() {
      isLoading = true;
    });
    bool loginSuccessful =
        await Provider.of<AuthProvider>(context, listen: false).login(
      init: true,
      username: idController.text,
      password: passwordController.text,
      context: context,
    );
    if (loginSuccessful) {
      // once login is successful load the image of the user as well
      if (mounted) {
        await Provider.of<AuthProvider>(context, listen: false).getMyDetails(
          init: true,
          context: context,
        );
      }
      if (mounted) {
        // Check if the widget is still mounted
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.success(
            message: "You have successfully logged in",
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
      }
    } else {
      if (mounted) {
        // Check if the widget is still mounted
        showTopSnackBar(
          Overlay.of(context),
          const CustomSnackBar.error(
            message: "Please enter the correct username and password",
          ),
        );
      }
    }
    setState(() {
      isLoading = false;
    });
    idController.clear();
    passwordController.clear();
  }
}
