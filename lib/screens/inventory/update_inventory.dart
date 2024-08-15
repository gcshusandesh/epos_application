import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class UpdateInventory extends StatefulWidget {
  const UpdateInventory({
    super.key,
    this.isEdit = false,
  });
  final bool isEdit;

  @override
  State<UpdateInventory> createState() => _UpdateInventoryState();
}

class _UpdateInventoryState extends State<UpdateInventory> {
  @override
  bool init = true;
  late double height;
  late double width;
  bool isLoading = false;
  bool isEditing = false;
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // A key for managing the form

  TextEditingController nameController = TextEditingController();

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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                buildTitleText(widget.isEdit ? "Edit Unit" : "Add Unit",
                    Data.darkTextColor, width),
                SizedBox(width: width * 5),
              ],
            ),
            SizedBox(height: height * 2),
            Container(
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
                      SizedBox(height: height * 2),
                      buildButton(
                        widget.isEdit ? Icons.update : Icons.create,
                        widget.isEdit ? "Update" : "Create",
                        height,
                        width,
                        () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });
                            late bool isSuccessful = false;
                            setState(() {
                              isLoading = false;
                            });
                            if (isSuccessful) {
                              if (mounted) {
                                Navigator.pop(context);
                                // show success massage
                                showTopSnackBar(
                                  Overlay.of(context),
                                  CustomSnackBar.success(
                                    message: widget.isEdit
                                        ? "Item Successfully Updated"
                                        : "Item Successfully Created",
                                  ),
                                );
                              }
                            } else {
                              if (mounted) {
                                // show error massage
                                showTopSnackBar(
                                  Overlay.of(context),
                                  CustomSnackBar.error(
                                    message: widget.isEdit
                                        ? "Item update failed"
                                        : "Item creation failed",
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
                ))
          ],
        ),
      ),
    );
  }

  Container dataBox({
    required String title,
    required String hintText,
    required TextEditingController controller,
    required Function? validator,
    bool isRequired = false,
    bool isNumber = false,
    Widget dropDown = const SizedBox(),
  }) {
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
