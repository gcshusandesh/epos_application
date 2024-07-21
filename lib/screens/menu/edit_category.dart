import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/auth_provider.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:epos_application/providers/menu_provider.dart';
import 'package:epos_application/screens/image_upload.dart';
import 'package:epos_application/screens/menu/update_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class EditCategory extends StatefulWidget {
  const EditCategory({super.key});
  static const routeName = "editCategory";

  @override
  State<EditCategory> createState() => _EditCategoryState();
}

class _EditCategoryState extends State<EditCategory> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  bool isLoading = false;
  bool isEditing = false;
  bool init = true;
  late double height;
  late double width;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (init) {
      //initialize size config at the very beginning
      SizeConfig().init(context);
      // here height and width have been swapped to tackle orientation swap
      width = SizeConfig.safeBlockVertical;
      height = SizeConfig.safeBlockHorizontal;

      init = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (bool value) {
        //for faster swapping of orientation
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      },
      child: Stack(
        children: [
          mainBody(context),
          isLoading
              ? Center(
                  child: onLoading(width: width, context: context),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  Scaffold mainBody(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            topSection(
                context: context,
                text: "Category",
                height: height,
                width: width),
            SizedBox(height: height * 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                iconButton(
                  "assets/svg/add.svg",
                  height,
                  width,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const UpdateData(
                                isCategory: true,
                              )),
                    );
                  },
                  context: context,
                ),
                SizedBox(width: width),
                iconButton(
                  "assets/svg/edit.svg",
                  height,
                  width,
                  () {
                    setState(() {
                      isEditing = !isEditing;
                    });
                  },
                  context: context,
                  isSelected: isEditing,
                ),
                // SizedBox(width: width),
                // textButton(
                //   text: "Change Priority",
                //   height: height,
                //   width: width,
                //   textColor: Provider.of<InfoProvider>(context, listen: true)
                //       .systemInfo
                //       .iconsColor,
                //   buttonColor:
                //       Provider.of<InfoProvider>(context, listen: true)
                //           .systemInfo
                //           .iconsColor,
                //   onTap: () {},
                // )
              ],
            ),
            SizedBox(height: height * 2),
            tableSection(context),
          ],
        ),
      ),
    );
  }

  Row topSection(
      {required BuildContext context,
      required double height,
      required String text,
      required double width}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        iconButton(
          "assets/svg/arrow_back.svg",
          height,
          width,
          () {
            Navigator.pop(context);
            //for faster swapping of orientation
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
          },
          context: context,
        ),
        buildTitleText(text, Data.darkTextColor, width),
        SizedBox(
          width: width * 5,
        ),
      ],
    );
  }

  Expanded tableSection(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Provider.of<MenuProvider>(context, listen: true)
                  .categoryList
                  .isEmpty
              ? Column(
                  children: [
                    Table(
                      border: TableBorder.all(color: Colors.black),
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(
                            decoration: const BoxDecoration(
                                color: Data.lightGreyBodyColor),
                            children: [
                              tableTitle("S.N.", width),
                              tableTitle("Name", width),
                              tableTitle("Image", width),
                              tableTitle("Action", width),
                              tableTitle("Status", width),
                            ]),
                      ],
                    ),
                    Container(
                      width: width * 100,
                      decoration: const BoxDecoration(
                        color: Data.lightGreyBodyColor,
                        border: Border(
                          left: BorderSide(color: Colors.black, width: 1),
                          right: BorderSide(color: Colors.black, width: 1),
                          bottom: BorderSide(color: Colors.black, width: 1),
                        ),
                      ),
                      child: Center(
                        child: buildSmallText("No Data Available",
                            Data.lightGreyTextColor, width),
                      ),
                    )
                  ],
                )
              : Table(
                  border: TableBorder.all(color: Colors.black),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                        decoration:
                            const BoxDecoration(color: Data.lightGreyBodyColor),
                        children: [
                          tableTitle("S.N.", width),
                          tableTitle("Name", width),
                          tableTitle("Image", width),
                          tableTitle("Action", width),
                          tableTitle("Status", width),
                        ]),
                    for (int index = 0;
                        index <
                            Provider.of<MenuProvider>(context, listen: true)
                                .categoryList
                                .length;
                        index++)
                      buildSpecialsRow(index),
                  ],
                ),
        ),
      ),
    );
  }

  TableRow buildSpecialsRow(int index) {
    return TableRow(
      decoration: const BoxDecoration(color: Data.lightGreyBodyColor),
      children: [
        tableItem((index + 1).toString(), width),
        InkWell(
          onTap: () {
            if (isEditing) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UpdateData(
                          isCategory: true,
                          category:
                              Provider.of<MenuProvider>(context, listen: false)
                                  .categoryList[index],
                          isEdit: true,
                          index: index,
                        )),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              children: [
                tableItem(
                    Provider.of<MenuProvider>(context, listen: true)
                        .categoryList[index]
                        .name,
                    width),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildCustomText(
                      Provider.of<MenuProvider>(context, listen: true)
                              .categoryList[index]
                              .status
                          ? "Active"
                          : "Inactive",
                      Provider.of<MenuProvider>(context, listen: true)
                              .categoryList[index]
                              .status
                          ? Data.greenColor
                          : Data.redColor,
                      width,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: width),
                      child: isEditing
                          ? label(
                              text: "edit",
                              height: height,
                              width: width,
                              labelColor: Provider.of<InfoProvider>(context,
                                      listen: true)
                                  .systemInfo
                                  .iconsColor)
                          : const SizedBox(),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            if (isEditing) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ImageUpload(
                          isCategoryImage: true,
                          category:
                              Provider.of<MenuProvider>(context, listen: false)
                                  .categoryList[index],
                          index: index,
                        )),
              );
            }
          },
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: width * 5, vertical: 15.0),
            child: Provider.of<MenuProvider>(context, listen: true)
                        .categoryList[index]
                        .image ==
                    null
                ? Container(
                    height: height * 10,
                    width: width * 20,
                    color: Colors.white60,
                    child: Center(
                      child: buildCustomText(
                        "No Image",
                        Data.greyTextColor,
                        width * 1.3,
                      ),
                    ),
                  )
                : Image.network(
                    Provider.of<MenuProvider>(context, listen: true)
                        .categoryList[index]
                        .image!,
                    height: height * 10,
                    width: width * 20,
                    fit: BoxFit.fill,
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 6),
          child: textButton(
            text: "Delete",
            height: height,
            width: width,
            textColor: Data.redColor,
            buttonColor: Data.redColor,
            onTap: () async {
              setState(() {
                isLoading = true;
              });
              // delete item from list
              bool isDeleted =
                  await Provider.of<MenuProvider>(context, listen: false)
                      .deleteMenuItem(
                index: index,
                id: Provider.of<MenuProvider>(context, listen: false)
                    .categoryList[index]
                    .id!,
                accessToken: Provider.of<AuthProvider>(context, listen: false)
                    .user
                    .accessToken!,
                isCategory: true,
                context: context,
              );
              setState(() {
                isLoading = false;
              });
              if (isDeleted) {
                if (mounted) {
                  // Check if the widget is still mounted
                  showTopSnackBar(
                    Overlay.of(context),
                    const CustomSnackBar.success(
                      message: "Item successfully deleted.",
                    ),
                  );
                }
              } else {
                if (mounted) {
                  // Check if the widget is still mounted
                  showTopSnackBar(
                    Overlay.of(context),
                    const CustomSnackBar.error(
                      message: "Item could not be deleted",
                    ),
                  );
                }
              }
            },
          ),
        ),
        buildCupertinoSwitch(
          index: index,
          value: Provider.of<MenuProvider>(context, listen: true)
              .categoryList[index]
              .status,
          onChanged: (value) async {
            if (Provider.of<MenuProvider>(context, listen: false)
                    .categoryList[index]
                    .image ==
                null) {
              // show success massage
              showTopSnackBar(
                Overlay.of(context),
                const CustomSnackBar.error(
                  message: "Please add image to publish category",
                ),
              );
            } else {
              setState(() {
                isLoading = true;
              });
              bool isUpdatedStatus =
                  await Provider.of<MenuProvider>(context, listen: false)
                      .updateMenuItem(
                isCategory: true,
                index: index,
                editedCategory: Category(
                  name: Provider.of<MenuProvider>(context, listen: false)
                      .categoryList[index]
                      .name,
                  id: Provider.of<MenuProvider>(context, listen: false)
                      .categoryList[index]
                      .id!,
                  image: Provider.of<MenuProvider>(context, listen: false)
                      .categoryList[index]
                      .image!,
                  status: value,
                ),
                accessToken: Provider.of<AuthProvider>(context, listen: false)
                    .user
                    .accessToken!,
                context: context,
              );
              setState(() {
                isLoading = false;
              });
              if (isUpdatedStatus) {
                if (mounted) {
                  // Check if the widget is still mounted
                  showTopSnackBar(
                    Overlay.of(context),
                    const CustomSnackBar.success(
                      message: "Item status updated successfully",
                    ),
                  );
                }
              } else {
                if (mounted) {
                  // Check if the widget is still mounted
                  showTopSnackBar(
                    Overlay.of(context),
                    const CustomSnackBar.error(
                      message: "Item status not updated",
                    ),
                  );
                }
              }
            }
          },
          context: context,
        ),
      ],
    );
  }
}
