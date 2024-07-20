import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/auth_provider.dart';
import 'package:epos_application/providers/menu_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class UpdateData extends StatefulWidget {
  const UpdateData({
    super.key,
    this.isSpecial = false,
    this.isCategory = false,
    this.isItem = false,
    this.isEdit = false,
  });
  final bool isSpecial;
  final bool isCategory;
  final bool isItem;
  final bool isEdit;
  static const String routeName = 'updateData';

  @override
  State<UpdateData> createState() => _UpdateDataState();
}

class _UpdateDataState extends State<UpdateData> {
  bool init = true;
  late double height;
  late double width;
  bool isLoading = false;
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // A key for managing the form

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

  TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        mainBody(),
        isLoading
            ? Center(
                child: onLoading(width: width, context: context),
              )
            : const SizedBox(),
      ],
    );
  }

  Scaffold mainBody() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                widget.isSpecial
                    ? buildTitleText(
                        widget.isEdit ? "Edit Specials" : "Add Specials",
                        Data.darkTextColor,
                        width)
                    : widget.isCategory
                        ? buildTitleText(
                            widget.isEdit ? "Edit Category" : "Add Category",
                            Data.darkTextColor,
                            width)
                        : buildTitleText(
                            widget.isEdit ? "Edit Menu Item" : "Add Menu Item",
                            Data.darkTextColor,
                            width),
                SizedBox(width: width * 5),
              ],
            ),
            SizedBox(height: height * 2),
            Center(
              child: Container(
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      widget.isSpecial
                          ? specialsForm()
                          : widget.isCategory
                              ? categoryForm()
                              : itemForm(),
                      SizedBox(height: height * 2),
                      buildButton(
                        Icons.fastfood,
                        widget.isEdit ? "Update" : "Create",
                        height,
                        width,
                        () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            late bool isCreated;
                            if (widget.isSpecial) {
                              isCreated = await specialLogic();
                            } else if (widget.isCategory) {
                              isCreated = await categoryLogic();
                            } else {
                              isCreated = await itemLogic();
                            }
                            setState(() {
                              isLoading = false;
                            });

                            if (isCreated) {
                              if (mounted) {
                                Navigator.pop(context);
                                // show success massage
                                showTopSnackBar(
                                  Overlay.of(context),
                                  const CustomSnackBar.success(
                                    message: "Item Successfully Created",
                                  ),
                                );
                              }
                            } else {
                              if (mounted) {
                                // show error massage
                                showTopSnackBar(
                                  Overlay.of(context),
                                  const CustomSnackBar.error(
                                    message: "Item creation failed",
                                  ),
                                );
                              }
                            }
                          }
                        },
                        context,
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

  Future<bool> specialLogic() async {
    bool isCreated =
        await Provider.of<MenuProvider>(context, listen: false).createMenuItem(
      isSpecials: true,
      specials: Specials(
        name: nameController.text,

        ///always set status to false when creating a new item
        status: false,
      ),
      accessToken:
          Provider.of<AuthProvider>(context, listen: false).user.accessToken!,
      context: context,
    );

    return isCreated;
  }

  Widget specialsForm() {
    return Column(
      children: [
        dataBox(
          title: "Item Name",
          hintText: "Item Name",
          isRequired: true,
          controller: nameController,
          validator: (value) {
            if (value.isEmpty) {
              return 'Enter a valid name!';
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<bool> categoryLogic() async {
    return false;
  }

  Widget categoryForm() {
    return Column(
      children: [
        dataBox(
          title: "Item Name",
          hintText: "Item Name",
          isRequired: true,
          controller: nameController,
          validator: (value) {
            if (value.isEmpty) {
              return 'Enter a valid name!';
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<bool> itemLogic() async {
    return false;
  }

  Widget itemForm() {
    return Column(
      children: [
        dataBox(
          title: "Item Name",
          hintText: "Item Name",
          isRequired: true,
          controller: nameController,
          validator: (value) {
            if (value.isEmpty) {
              return 'Enter a valid name!';
            }
            return null;
          },
        ),
      ],
    );
  }

  Container dataBox(
      {required String title,
      required String hintText,
      required TextEditingController controller,
      required Function? validator,
      bool isRequired = false,
      bool isNumber = false,
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
          buildInputField(hintText, height, width, context, controller,
              validator: validator, isNumber: isNumber),
        ],
      ),
    );
  }
}
