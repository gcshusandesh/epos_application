import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/menu_provider.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

class EditMenu extends StatefulWidget {
  const EditMenu({super.key});
  static const routeName = "editMenu";

  @override
  State<EditMenu> createState() => _EditMenuState();
}

class _EditMenuState extends State<EditMenu> {
  bool init = true;
  late double height;
  late double width;

  @override
  void didChangeDependencies() {
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
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (bool value) async {
        Provider.of<MenuProvider>(context, listen: false).resetCategory();
      },
      child: Scaffold(
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
      ),
    );
  }

  Expanded optionsSection(BuildContext context) {
    return Expanded(
      flex: 1,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        scrollDirection:
            Axis.horizontal, // Assuming you want a horizontal list view
        itemCount: Provider.of<MenuProvider>(context, listen: true)
            .categoryList
            .length,
        itemBuilder: (context, index) {
          final category = Provider.of<MenuProvider>(context, listen: true)
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
          },
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
        iconButton(
          "assets/svg/add.svg",
          height,
          width,
          () {
            showMaterialModalBottomSheet(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
              ),
              backgroundColor: Data.lightGreyBodyColor,
              context: context,
              builder: (context) => SizedBox(
                height: height * 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: height * 2),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.black, // Outline color
                          width: 0.5, // Outline width
                        ),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      height: 10,
                      width: width * 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        SizedBox(width: width),
        iconButton(
          "assets/svg/edit.svg",
          height,
          width,
          () {
            //do something
          },
        ),
        SizedBox(width: width),
        textButton(
          text: "Change Priority",
          height: height,
          width: width,
          textColor: Data.iconsColor,
          buttonColor: Data.iconsColor,
          onTap: () {},
        )
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
        tableItem((itemIndex + 1).toString(), width),
        Padding(
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
                  width),
              buildCustomText(
                Provider.of<MenuProvider>(context, listen: true)
                        .menuItemsByCategory[
                            Provider.of<MenuProvider>(context, listen: true)
                                .selectedCategoryIndex]
                        .menuItems[itemIndex]
                        .status
                    ? "Active"
                    : "Inactive",
                Provider.of<MenuProvider>(context, listen: true)
                        .menuItemsByCategory[
                            Provider.of<MenuProvider>(context, listen: true)
                                .selectedCategoryIndex]
                        .menuItems[itemIndex]
                        .status
                    ? Data.greenColor
                    : Data.redColor,
                width,
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Image.asset(
            Provider.of<MenuProvider>(context, listen: true)
                .menuItemsByCategory[
                    Provider.of<MenuProvider>(context, listen: true)
                        .selectedCategoryIndex]
                .menuItems[itemIndex]
                .image,
            height: height * 10,
            width: width * 20,
            fit: BoxFit.fill,
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
        ),
        tableItem(
          Provider.of<MenuProvider>(context, listen: true)
              .menuItemsByCategory[
                  Provider.of<MenuProvider>(context, listen: true)
                      .selectedCategoryIndex]
              .menuItems[itemIndex]
              .ingredients,
          width,
        ),
        tableItem(
          "£ ${Provider.of<MenuProvider>(context, listen: true).menuItemsByCategory[Provider.of<MenuProvider>(context, listen: true).selectedCategoryIndex].menuItems[itemIndex].price}",
          width,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 2),
          child: textButton(
            text: "Delete",
            height: height,
            width: width,
            textColor: Data.redColor,
            buttonColor: Data.redColor,
            onTap: () {
              // delete item from list
              Provider.of<MenuProvider>(context, listen: false)
                  .removeMenuItem(itemIndex: itemIndex);
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
            onChanged: (value) {
              Provider.of<MenuProvider>(context, listen: false)
                  .changeMenuItemStatus(itemIndex: itemIndex);
            }),
      ],
    );
  }
}
