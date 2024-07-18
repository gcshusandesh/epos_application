import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/auth_provider.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:epos_application/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class CreateEmployee extends StatefulWidget {
  const CreateEmployee({
    super.key,
    this.isEdit = false,
    this.user,
    this.index,
  });
  static const routeName = "makeEmployee";
  final bool isEdit;
  final UserDataModel? user;
  final int? index;

  @override
  State<CreateEmployee> createState() => _CreateEmployeeState();
}

class _CreateEmployeeState extends State<CreateEmployee> {
  bool isLoading = false;
  bool init = true;
  late double height;
  late double width;

  String? genderDropdownValue;
  String? typeDropdownValue;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController placeHolderController = TextEditingController();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (init) {
      //initialize size config at the very beginning
      SizeConfig().init(context);
      height = SizeConfig.safeBlockVertical;
      width = SizeConfig.safeBlockHorizontal;
      if (widget.isEdit) {
        // populate controller with current employee value
        nameController.text = widget.user!.name;
        emailController.text = widget.user!.email;
        phoneController.text = widget.user!.phone;
        genderDropdownValue = widget.user!.gender;
        typeDropdownValue = widget.user!.userType.name;
      }

      init = false;
    }
  }

  @override
  void dispose() {
    //to save memory
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    placeHolderController.dispose();
    super.dispose();
  }

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // A key for managing the form

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
      body: Padding(
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
                        offset: const Offset(0, 5), // The offset of the shadow
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        buildTitleText(
                            widget.isEdit ? "Edit Employee" : "Create Employee",
                            Data.darkTextColor,
                            width * 0.8),
                        SizedBox(height: height),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Container(
                                width: width * 15,
                                height: width * 15,
                                padding: EdgeInsets.all(widget.isEdit &&
                                        ((widget.user!.imageUrl) != null)
                                    ? 0
                                    : width * 3),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Data.lightGreyBodyColor,
                                ),
                                child: Center(
                                  child: widget.isEdit &&
                                          ((widget.user!.imageUrl) != null)
                                      ? ClipOval(
                                          child: buildImage(
                                              widget.user!.imageUrl!,
                                              width * 15,
                                              width * 15,
                                              isNetworkImage: true,
                                              context: context),
                                        )
                                      : SvgPicture.asset(
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
                              dataBox(
                                title: "Full Name",
                                hintText: "Full Name",
                                isRequired: true,
                                controller: nameController,
                              ),
                              SizedBox(height: height),
                              dataBox(
                                title: "Email",
                                hintText: "Email",
                                isRequired: true,
                                controller: emailController,
                              ),
                              SizedBox(height: height),
                              widget.isEdit
                                  ? const SizedBox()
                                  : dataBox(
                                      title: "Password",
                                      hintText: "Password",
                                      isRequired: true,
                                      controller: passwordController,
                                    ),
                              SizedBox(
                                height: widget.isEdit ? 0 : height,
                              ),
                              dataBox(
                                title: "Phone",
                                hintText: "Phone",
                                isRequired: true,
                                controller: phoneController,
                              ),
                              SizedBox(height: height),
                              dataBox(
                                title: "Gender",
                                hintText: "Gender",
                                isRequired: true,
                                isDropDown: true,
                                controller: placeHolderController,
                                dropDown: DropdownButtonFormField<String>(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                      Icons.arrow_drop_down_circle_outlined),
                                  iconSize: width * 2,
                                  iconDisabledColor: Provider.of<InfoProvider>(
                                          context,
                                          listen: true)
                                      .systemInfo
                                      .iconsColor,
                                  iconEnabledColor: Provider.of<InfoProvider>(
                                          context,
                                          listen: true)
                                      .systemInfo
                                      .iconsColor,
                                  decoration: InputDecoration(
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Data
                                            .lightGreyBodyColor, // Custom focused border color
                                        width:
                                            1, // Custom focused border width (optional)
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Provider.of<InfoProvider>(
                                                context,
                                                listen: true)
                                            .systemInfo
                                            .primaryColor, // Custom focused border color
                                        width:
                                            2.0, // Custom focused border width (optional)
                                      ),
                                    ),
                                  ),
                                  hint: const Text('Select'),
                                  dropdownColor: Colors.white,
                                  value: genderDropdownValue,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      genderDropdownValue = newValue!;
                                    });
                                  },
                                  items: <String>[
                                    'Male',
                                    'Female',
                                    'Others',
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(height: height),
                              dataBox(
                                title: "User Type",
                                hintText: "User Type",
                                isRequired: true,
                                isDropDown: true,
                                controller: placeHolderController,
                                dropDown: DropdownButtonFormField<String>(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                      Icons.arrow_drop_down_circle_outlined),
                                  iconSize: width * 2,
                                  iconDisabledColor: Provider.of<InfoProvider>(
                                          context,
                                          listen: true)
                                      .systemInfo
                                      .iconsColor,
                                  iconEnabledColor: Provider.of<InfoProvider>(
                                          context,
                                          listen: true)
                                      .systemInfo
                                      .iconsColor,
                                  decoration: InputDecoration(
                                    enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Data
                                            .lightGreyBodyColor, // Custom focused border color
                                        width:
                                            1, // Custom focused border width (optional)
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Provider.of<InfoProvider>(
                                                context,
                                                listen: true)
                                            .systemInfo
                                            .primaryColor, // Custom focused border color
                                        width:
                                            2.0, // Custom focused border width (optional)
                                      ),
                                    ),
                                  ),
                                  hint: const Text('Select'),
                                  dropdownColor: Colors.white,
                                  value: typeDropdownValue,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      typeDropdownValue = newValue!;
                                    });
                                  },
                                  items: <String>[
                                    UserType.owner.name,
                                    UserType.manager.name,
                                    UserType.chef.name,
                                    UserType.waiter.name,
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(height: height),
                              buildButton(
                                Icons.person,
                                widget.isEdit ? "Update" : "Create",
                                height,
                                width,
                                () async {
                                  // TODO: add form validation here
                                  setState(() {
                                    isLoading = true;
                                  });
                                  late bool isSuccessful;
                                  if (widget.isEdit) {
                                    /// edit employee data
                                    isSuccessful =
                                        await Provider.of<AuthProvider>(context,
                                                listen: false)
                                            .updateUserDetails(
                                                context: context,
                                                editedDetails: UserDataModel(
                                                  id: widget.user!.id,
                                                  name: nameController.text,
                                                  email: emailController.text,
                                                  phone: phoneController.text,
                                                  gender: genderDropdownValue!,
                                                  userType: assignUserType(
                                                      typeDropdownValue!),
                                                  isBlocked:
                                                      widget.user!.isBlocked,
                                                ));
                                  } else {
                                    /// create employee
                                    isSuccessful =
                                        await Provider.of<UserProvider>(context,
                                                listen: false)
                                            .createUser(
                                      name: nameController.text,
                                      email: emailController.text,
                                      password: passwordController.text,
                                      phone: phoneController.text,
                                      gender: genderDropdownValue!,
                                      userType: typeDropdownValue!,
                                      context: context,
                                    );
                                  }

                                  setState(() {
                                    isLoading = false;
                                  });

                                  if (isSuccessful && widget.isEdit) {
                                    /// show success message for employee edit
                                    if (context.mounted) {
                                      Provider.of<UserProvider>(context,
                                              listen: false)
                                          .editUserLocally(
                                        index: widget.index!,
                                        editedUser: UserDataModel(
                                          name: nameController.text,
                                          email: emailController.text,
                                          phone: phoneController.text,
                                          gender: genderDropdownValue!,
                                          userType: assignUserType(
                                              typeDropdownValue!),
                                          isBlocked: widget.user!.isBlocked,
                                        ),
                                      );
                                      Navigator.pop(context);
                                      // show success massage
                                      showTopSnackBar(
                                        Overlay.of(context),
                                        const CustomSnackBar.success(
                                          message:
                                              "Employee Edited Successfully",
                                        ),
                                      );
                                    }
                                  } else if (isSuccessful && !widget.isEdit) {
                                    /// show success message for employee creation
                                    if (context.mounted) {
                                      Provider.of<UserProvider>(context,
                                              listen: false)
                                          .addUserLocally(UserDataModel(
                                        name: nameController.text,
                                        email: emailController.text,
                                        phone: phoneController.text,
                                        gender: genderDropdownValue!,
                                        isBlocked: false,
                                        userType:
                                            assignUserType(typeDropdownValue!),
                                      ));
                                      Navigator.pop(context);
                                      // show success massage
                                      showTopSnackBar(
                                        Overlay.of(context),
                                        const CustomSnackBar.success(
                                          message:
                                              "Employee Created Successfully",
                                        ),
                                      );
                                    }
                                  } else {
                                    /// show error massage
                                    if (context.mounted) {
                                      showTopSnackBar(
                                        Overlay.of(context),
                                        CustomSnackBar.error(
                                          message: widget.isEdit
                                              ? "Employee Edit Failed"
                                              : "Employee Creation Failed",
                                        ),
                                      );
                                    }
                                  }
                                },
                                context,
                              ),
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
    );
  }

  UserType assignUserType(String userType) {
    if (userType == "owner") {
      return UserType.owner;
    } else if (userType == "manager") {
      return UserType.manager;
    } else if (userType == "waiter") {
      return UserType.waiter;
    } else {
      return UserType.chef;
    }
  }

  Container dataBox(
      {required String title,
      required String hintText,
      required TextEditingController controller,
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
          isDropDown
              ? dropDown
              : buildInputField(hintText, height, width, context, controller),
        ],
      ),
    );
  }
}
