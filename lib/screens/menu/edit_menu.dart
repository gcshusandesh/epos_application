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

class EditMenu extends StatefulWidget {
  const EditMenu({super.key});
  static const routeName = "editMenu";

  @override
  State<EditMenu> createState() => _EditMenuState();
}

class _EditMenuState extends State<EditMenu> {
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
      onPopInvoked: (bool value) async {
        Provider.of<MenuProvider>(context, listen: false).resetCategory();
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
                text: "Menu Item",
                height: height,
                width: width),
            optionsSection(context),
            SizedBox(height: height * 2),
            editSection(context),
            SizedBox(height: height * 2),
            tableSection(context),
          ],
        ),
      ),
    );
  }

  Widget optionsSection(BuildContext context) {
    return Provider.of<MenuProvider>(context, listen: true).categoryList.isEmpty
        ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: width * 1,
                ),
                height: width * 10,
                width: width * 10,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Provider.of<InfoProvider>(context, listen: true)
                        .systemInfo
                        .iconsColor, // Outline color
                    width: 0.5, // Outline width
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25), // Shadow color
                      spreadRadius: 0, // How much the shadow spreads
                      blurRadius: 4, // How much the shadow blurs
                      offset: const Offset(0, 5), // The offset of the shadow
                    ),
                  ],
                ),
                child: Center(
                  child: buildCustomText(
                    "No Data",
                    Data.darkTextColor,
                    width * 1.5,
                  ),
                ),
              ),
            ],
          )
        : Expanded(
            flex: 1,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              scrollDirection:
                  Axis.horizontal, // Assuming you want a horizontal list view
              itemCount: Provider.of<MenuProvider>(context, listen: true)
                  .categoryList
                  .length,
              itemBuilder: (context, index) {
                final category =
                    Provider.of<MenuProvider>(context, listen: true)
                        .categoryList[index];
                return Row(
                  children: [
                    menuOption(
                      category.name,
                      category.image,
                      height,
                      width,
                      () {
                        Provider.of<MenuProvider>(context, listen: false)
                            .changeSelectedCategory(index);
                      },
                      index: index,
                      context: context,
                    ),
                    SizedBox(width: width),
                  ],
                );
              },
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
            Provider.of<MenuProvider>(context, listen: false).resetCategory();

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

  Row editSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Provider.of<MenuProvider>(context, listen: false).categoryList.isEmpty
            ? const SizedBox()
            : iconButton(
                "assets/svg/add.svg",
                height,
                width,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UpdateData(
                              isItem: true,
                              selectedCategory: Provider.of<MenuProvider>(
                                      context,
                                      listen: false)
                                  .categoryList[Provider.of<MenuProvider>(
                                          context,
                                          listen: true)
                                      .selectedCategoryIndex]
                                  .name,
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
        //   buttonColor: Provider.of<InfoProvider>(context, listen: true)
        //       .systemInfo
        //       .iconsColor,
        //   onTap: () {},
        // )
      ],
    );
  }

  Widget tableSection(BuildContext context) {
    return Expanded(
      flex: 2,
      child: SingleChildScrollView(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Provider.of<MenuProvider>(context, listen: true)
                      .menuItemsByCategory
                      .isEmpty ||
                  Provider.of<MenuProvider>(context, listen: true)
                      .menuItemsByCategory[
                          Provider.of<MenuProvider>(context, listen: true)
                              .selectedCategoryIndex]
                      .menuItems
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
                              tableTitle("Description", width),
                              tableTitle("Ingredients", width),
                              tableTitle("Price", width),
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
                          tableTitle("Description", width),
                          tableTitle("Ingredients", width),
                          tableTitle("Price", width),
                          tableTitle("Action", width),
                          tableTitle("Status", width),
                        ]),
                    for (int index = 0;
                        index <
                            Provider.of<MenuProvider>(context, listen: true)
                                .menuItemsByCategory[Provider.of<MenuProvider>(
                                        context,
                                        listen: true)
                                    .selectedCategoryIndex]
                                .menuItems
                                .length;
                        index++)
                      buildMenuRow(index),
                  ],
                ),
        ),
      ),
    );
  }

  TableRow buildMenuRow(int itemIndex) {
    return TableRow(
      decoration: const BoxDecoration(color: Data.lightGreyBodyColor),
      children: [
        tableItem((itemIndex + 1).toString(), width, context),
        InkWell(
          onTap: () {
            if (isEditing) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UpdateData(
                          isItem: true,
                          menuItems:
                              Provider.of<MenuProvider>(context, listen: false)
                                  .menuItemsByCategory[
                                      Provider.of<MenuProvider>(context,
                                              listen: false)
                                          .selectedCategoryIndex]
                                  .menuItems[itemIndex],
                          isEdit: true,
                          index: itemIndex,
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
                        .menuItemsByCategory[
                            Provider.of<MenuProvider>(context, listen: true)
                                .selectedCategoryIndex]
                        .menuItems[itemIndex]
                        .name,
                    width,
                    context),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildCustomText(
                      Provider.of<MenuProvider>(context, listen: true)
                              .menuItemsByCategory[Provider.of<MenuProvider>(
                                      context,
                                      listen: true)
                                  .selectedCategoryIndex]
                              .menuItems[itemIndex]
                              .status
                          ? "Active"
                          : "Inactive",
                      Provider.of<MenuProvider>(context, listen: true)
                              .menuItemsByCategory[Provider.of<MenuProvider>(
                                      context,
                                      listen: true)
                                  .selectedCategoryIndex]
                              .menuItems[itemIndex]
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
                          isItemImage: true,
                          menuItems:
                              Provider.of<MenuProvider>(context, listen: false)
                                  .menuItemsByCategory[
                                      Provider.of<MenuProvider>(context,
                                              listen: false)
                                          .selectedCategoryIndex]
                                  .menuItems[itemIndex],
                          index: itemIndex,
                        )),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Provider.of<MenuProvider>(context, listen: true)
                        .menuItemsByCategory[
                            Provider.of<MenuProvider>(context, listen: true)
                                .selectedCategoryIndex]
                        .menuItems[itemIndex]
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
                : buildImage(
                    Provider.of<MenuProvider>(context, listen: true)
                        .menuItemsByCategory[
                            Provider.of<MenuProvider>(context, listen: true)
                                .selectedCategoryIndex]
                        .menuItems[itemIndex]
                        .image!,
                    height * 10,
                    width * 20,
                    context: context,
                    isNetworkImage: true),
          ),
        ),
        tableItem(
          Provider.of<MenuProvider>(context, listen: true)
              .menuItemsByCategory[
                  Provider.of<MenuProvider>(context, listen: true)
                      .selectedCategoryIndex]
              .menuItems[itemIndex]
              .description,
          width,
          context,
        ),
        tableItem(
          Provider.of<MenuProvider>(context, listen: true)
              .menuItemsByCategory[
                  Provider.of<MenuProvider>(context, listen: true)
                      .selectedCategoryIndex]
              .menuItems[itemIndex]
              .ingredients,
          width,
          context,
        ),
        tableItem(
          "${Provider.of<InfoProvider>(context, listen: true).systemInfo.currencySymbol!} ${Provider.of<MenuProvider>(context, listen: true).menuItemsByCategory[Provider.of<MenuProvider>(context, listen: true).selectedCategoryIndex].menuItems[itemIndex].price}",
          width,
          context,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 2),
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
                index: itemIndex,
                id: Provider.of<MenuProvider>(context, listen: false)
                    .menuItemsByCategory[
                        Provider.of<MenuProvider>(context, listen: false)
                            .selectedCategoryIndex]
                    .menuItems[itemIndex]
                    .id!,
                accessToken: Provider.of<AuthProvider>(context, listen: false)
                    .user
                    .accessToken!,
                isItem: true,
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
          index: itemIndex,
          value: Provider.of<MenuProvider>(context, listen: true)
              .menuItemsByCategory[
                  Provider.of<MenuProvider>(context, listen: true)
                      .selectedCategoryIndex]
              .menuItems[itemIndex]
              .status,
          onChanged: (value) async {
            // Provider.of<MenuProvider>(context, listen: false)
            //     .changeMenuItemStatusLocally(itemIndex: itemIndex);
            if (Provider.of<MenuProvider>(context, listen: false)
                    .menuItemsByCategory[
                        Provider.of<MenuProvider>(context, listen: false)
                            .selectedCategoryIndex]
                    .menuItems[itemIndex]
                    .image ==
                null) {
              // show success massage
              showTopSnackBar(
                Overlay.of(context),
                const CustomSnackBar.error(
                  message: "Please add image to publish item",
                ),
              );
            } else {
              setState(() {
                isLoading = true;
              });
              bool isUpdatedStatus =
                  await Provider.of<MenuProvider>(context, listen: false)
                      .updateMenuItem(
                isItem: true,
                index: itemIndex,
                editedMenuItems: MenuItems(
                  name: Provider.of<MenuProvider>(context, listen: false)
                      .menuItemsByCategory[
                          Provider.of<MenuProvider>(context, listen: false)
                              .selectedCategoryIndex]
                      .menuItems[itemIndex]
                      .name,
                  id: Provider.of<MenuProvider>(context, listen: false)
                      .menuItemsByCategory[
                          Provider.of<MenuProvider>(context, listen: false)
                              .selectedCategoryIndex]
                      .menuItems[itemIndex]
                      .id!,
                  image: Provider.of<MenuProvider>(context, listen: false)
                      .menuItemsByCategory[
                          Provider.of<MenuProvider>(context, listen: false)
                              .selectedCategoryIndex]
                      .menuItems[itemIndex]
                      .image!,
                  description: Provider.of<MenuProvider>(context, listen: false)
                      .menuItemsByCategory[
                          Provider.of<MenuProvider>(context, listen: false)
                              .selectedCategoryIndex]
                      .menuItems[itemIndex]
                      .description,
                  ingredients: Provider.of<MenuProvider>(context, listen: false)
                      .menuItemsByCategory[
                          Provider.of<MenuProvider>(context, listen: false)
                              .selectedCategoryIndex]
                      .menuItems[itemIndex]
                      .ingredients,
                  price: Provider.of<MenuProvider>(context, listen: false)
                      .menuItemsByCategory[
                          Provider.of<MenuProvider>(context, listen: false)
                              .selectedCategoryIndex]
                      .menuItems[itemIndex]
                      .price,
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
