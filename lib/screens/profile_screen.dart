import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/auth_provider.dart';
import 'package:epos_application/providers/extra_provider.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:epos_application/screens/image_upload.dart';
import 'package:epos_application/screens/reset_password.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const routeName = "profileScreen";

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false;
  bool init = true;
  late double height;
  late double width;

  String? genderDropDownValue;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  TextEditingController phoneController = TextEditingController();
  TextEditingController placeHolderGenderController = TextEditingController();
  TextEditingController placeHolderUserTypeController = TextEditingController();

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (init) {
      //initialize size config at the very beginning
      SizeConfig().init(context);
      height = SizeConfig.safeBlockVertical;
      width = SizeConfig.safeBlockHorizontal;

      UserDataModel user =
          Provider.of<AuthProvider>(context, listen: false).user;
      // setting initial value as user details
      nameController.text = user.name;
      emailController.text = user.email;
      phoneController.text = user.phone;
      genderDropDownValue = user.gender;
      init = false;
    }
  }

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // A key for managing the form

  @override
  void dispose() {
    // TODO: implement dispose
    //to save memory
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    placeHolderGenderController.dispose();
    placeHolderUserTypeController.dispose();
    super.dispose();
  }

  bool isEditing = false;

  Future<void> _refresh() async {
    await Provider.of<AuthProvider>(context, listen: false)
        .getUserDetails(init: false, context: context);
    setState(() {
      UserDataModel user =
          Provider.of<AuthProvider>(context, listen: true).user;
      nameController.text = user.name;
      emailController.text = user.email;
      phoneController.text = user.phone;
      genderDropDownValue = user.gender;
    });
  }

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
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: Provider.of<InfoProvider>(context, listen: true)
            .systemInfo
            .primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
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
                          offset:
                              const Offset(0, 5), // The offset of the shadow
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              textButton(
                                text: "Change Password",
                                height: height * 0.75,
                                width: width * 0.75,
                                textColor: Provider.of<InfoProvider>(context,
                                        listen: true)
                                    .systemInfo
                                    .primaryColor,
                                buttonColor: Provider.of<InfoProvider>(context,
                                        listen: true)
                                    .systemInfo
                                    .primaryColor,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ResetPassword(
                                              isChangePassword: true,
                                            )),
                                  );
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              buildTitleText("My Profile", Data.darkTextColor,
                                  width * 0.8),
                              SizedBox(width: width),
                              iconButton(
                                "assets/svg/edit.svg",
                                height * 0.8,
                                width * 0.8,
                                () {
                                  setState(() {
                                    isEditing = !isEditing;
                                  });
                                },
                                context: context,
                              ),
                              SizedBox(width: width),
                              iconButton(
                                "assets/svg/logout.svg",
                                height * 0.8,
                                width * 0.8,
                                () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return alert();
                                    },
                                  );
                                },
                                context: context,
                              ),
                            ],
                          ),
                          SizedBox(height: height),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Container(
                                  width: width * 15,
                                  height: width * 15,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Data.lightGreyBodyColor,
                                  ),
                                  child: Center(
                                      child: InkWell(
                                    onTap: () async {
                                      // image picker
                                      if (isEditing) {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                          builder: (context) {
                                            return ImageUpload();
                                          },
                                        ));
                                      }
                                    },
                                    child: ClipOval(
                                      child: Stack(
                                        children: [
                                          Provider.of<AuthProvider>(context,
                                                          listen: true)
                                                      .user
                                                      .imageUrl ==
                                                  null
                                              ? Center(
                                                  child: Icon(
                                                    Icons.person,
                                                    size: width * 15,
                                                    color: Provider.of<
                                                                InfoProvider>(
                                                            context,
                                                            listen: true)
                                                        .systemInfo
                                                        .iconsColor,
                                                  ),
                                                )
                                              : buildImage(
                                                  Provider.of<AuthProvider>(
                                                          context,
                                                          listen: true)
                                                      .user
                                                      .imageUrl!,
                                                  width * 15,
                                                  width * 15,
                                                  isNetworkImage: true,
                                                  context: context,
                                                ),
                                          isEditing
                                              ? Align(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Container(
                                                    height: width * 2.25,
                                                    decoration: BoxDecoration(
                                                      color: Provider.of<
                                                                  InfoProvider>(
                                                              context,
                                                              listen: true)
                                                          .systemInfo
                                                          .primaryColor
                                                          .withOpacity(0.8),
                                                    ),
                                                    child: Center(
                                                      child: buildSmallText(
                                                          "Edit",
                                                          Colors.white,
                                                          width),
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox(),
                                          Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Container(
                                              height: width * 2.25,
                                              decoration: BoxDecoration(
                                                color: Data.greenColor
                                                    .withOpacity(0.8),
                                              ),
                                              child: Center(
                                                child: buildSmallText(
                                                    Provider.of<AuthProvider>(
                                                            context,
                                                            listen: true)
                                                        .user
                                                        .userType
                                                        .name,
                                                    Colors.white,
                                                    width),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                                ),
                                SizedBox(height: height),
                                dataBox(
                                  title: "Full Name",
                                  hintText: "Full Name",
                                  isRequired: false,
                                  controller: nameController,
                                  data: Provider.of<AuthProvider>(context,
                                          listen: true)
                                      .user
                                      .name,
                                ),
                                SizedBox(height: height),
                                dataBox(
                                  title: "Email",
                                  hintText: "Email",
                                  isRequired: false,
                                  controller: emailController,
                                  data: Provider.of<AuthProvider>(context,
                                          listen: true)
                                      .user
                                      .email,
                                ),
                                SizedBox(height: height),
                                dataBox(
                                  title: "Phone",
                                  hintText: "Phone",
                                  isRequired: false,
                                  controller: phoneController,
                                  data: Provider.of<AuthProvider>(context,
                                          listen: true)
                                      .user
                                      .phone,
                                ),
                                SizedBox(height: height),
                                buildDataBoxDropDown(
                                  context: context,
                                  title: "Gender",
                                  hintText: "Gender",
                                  dataList: <String>[
                                    'Male',
                                    'Female',
                                    'Others',
                                  ],
                                  controller: placeHolderGenderController,
                                ),
                                SizedBox(height: height),
                                isEditing
                                    ? buildButton(
                                        Icons.person,
                                        "Update",
                                        height,
                                        width,
                                        () async {
                                          final overlayContext =
                                              Overlay.of(context);
                                          //submit form
                                          // TODO: add form validation here
                                          setState(() {
                                            isLoading = true;
                                          });

                                          UserDataModel user =
                                              Provider.of<AuthProvider>(context,
                                                      listen: false)
                                                  .user;
                                          bool isUpdateSuccessful =
                                              await Provider.of<AuthProvider>(
                                                      context,
                                                      listen: false)
                                                  .updateUserDetails(
                                                      editedDetails:
                                                          UserDataModel(
                                                        id: user.id,
                                                        name:
                                                            nameController.text,
                                                        username:
                                                            usernameController
                                                                .text,
                                                        imageUrl: user.imageUrl,
                                                        email: emailController
                                                            .text,
                                                        phone: phoneController
                                                            .text,
                                                        gender:
                                                            genderDropDownValue!,
                                                        isBlocked:
                                                            user.isBlocked,
                                                        userType: user.userType,
                                                        accessToken:
                                                            user.accessToken,
                                                        isLoggedIn:
                                                            user.isLoggedIn,
                                                      ),
                                                      isLoggedIn: true,
                                                      context: context);
                                          setState(() {
                                            isLoading = false;
                                          });
                                          if (isUpdateSuccessful) {
                                            // show success massage
                                            showTopSnackBar(
                                              overlayContext,
                                              const CustomSnackBar.success(
                                                message:
                                                    "User Details Updated Successfully",
                                              ),
                                            );
                                            setState(() {
                                              isEditing = false;
                                            });
                                          } else {
                                            // show failure massage
                                            showTopSnackBar(
                                              overlayContext,
                                              const CustomSnackBar.error(
                                                message:
                                                    "User Details not updated",
                                              ),
                                            );
                                          }
                                        },
                                        context,
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // set up the AlertDialog
  Widget alert() {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("Logout"),
      content: const Text("Would you like to logout?"),
      actions: [
        textButton(
          text: "Yes",
          height: height,
          width: width,
          textColor: Data.greenColor,
          buttonColor: Data.greenColor,
          onTap: () {
            // logout
            Provider.of<AuthProvider>(context, listen: false)
                .logout(context: context);
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

  Container buildDataBoxDropDown({
    required BuildContext context,
    required String title,
    required String hintText,
    required List<String> dataList,
    required TextEditingController controller,
  }) {
    return dataBox(
      title: title,
      hintText: hintText,
      isRequired: false,
      isDropDown: true,
      controller: controller,
      data: Provider.of<AuthProvider>(context, listen: true).user.gender,
      dropDown: DropdownButtonFormField<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.arrow_drop_down_circle_outlined),
        iconSize: width * 2,
        iconDisabledColor: Provider.of<InfoProvider>(context, listen: true)
            .systemInfo
            .iconsColor,
        iconEnabledColor: Provider.of<InfoProvider>(context, listen: true)
            .systemInfo
            .iconsColor,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Data.lightGreyBodyColor, // Custom focused border color
              width: 1, // Custom focused border width (optional)
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Provider.of<InfoProvider>(context, listen: true)
                  .systemInfo
                  .primaryColor, // Custom focused border color
              width: 2.0, // Custom focused border width (optional)
            ),
          ),
        ),
        hint: const Text('Select'),
        dropdownColor: Colors.white,
        value: genderDropDownValue,
        onChanged: (String? newValue) {
          setState(() {
            genderDropDownValue = newValue!;
          });
        },
        items: dataList.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
            ),
          );
        }).toList(),
      ),
    );
  }

  Container dataBox(
      {required String title,
      required String hintText,
      required TextEditingController controller,
      bool isPasswordField = false,
      String data = "",
      bool isRequired = false,
      bool isDropDown = false,
      Widget dropDown = const SizedBox()}) {
    return Container(
      width: width * 31,
      padding: EdgeInsets.symmetric(vertical: height, horizontal: width * 2),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              buildCustomText(title, Data.lightGreyTextColor, width * 1.4,
                  fontFamily: "RobotoMedium"),
              isRequired
                  ? buildSmallText(
                      "*",
                      Data.redColor,
                      width,
                    )
                  : const SizedBox(),
            ],
          ),
          !isEditing
              ? Container(
                  width: width * 31,
                  padding: EdgeInsets.symmetric(
                    vertical: height,
                    horizontal: width,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Data.lightGreyBodyColor),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: buildCustomText(
                      data, Data.lightGreyTextColor, width * 1.4,
                      fontFamily: "RobotoMedium"),
                )
              : isDropDown
                  ? dropDown
                  : isPasswordField
                      ? buildPasswordField(
                          "Password",
                          height,
                          width,
                          context,
                          controller,
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
                            return null;
                          },
                        )
                      : buildInputField(
                          hintText, height, width, context, controller),
        ],
      ),
    );
  }
}
