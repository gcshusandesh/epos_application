import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/auth_provider.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:epos_application/providers/inventory_provider.dart';
import 'package:epos_application/screens/inventory/edit_unit.dart';
import 'package:epos_application/screens/inventory/update_inventory.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ViewInventory extends StatefulWidget {
  const ViewInventory({super.key});

  @override
  State<ViewInventory> createState() => _ViewInventoryState();
}

class _ViewInventoryState extends State<ViewInventory> {
  bool init = true;
  late double height;
  late double width;
  bool isLoading = false;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (init) {
      //initialize size config at the very beginning
      SizeConfig().init(context);
      height = SizeConfig.safeBlockVertical;
      width = SizeConfig.safeBlockHorizontal;
      initialCheck = true;
      init = false;
    }
  }

  void _fetchData() async {
    setState(() {
      isLoading = true;
    });
    await Provider.of<InventoryProvider>(context, listen: false)
        .getInventoryList(
            accessToken: Provider.of<AuthProvider>(context, listen: false)
                .user
                .accessToken!,
            context: context);
    if (mounted) {
      await Provider.of<InventoryProvider>(context, listen: false).getUnitTypes(
          accessToken: Provider.of<AuthProvider>(context, listen: false)
              .user
              .accessToken!,
          context: context);
    }
    setState(() {
      isLoading = false;
    });
  }

  bool initialCheck = false;

  @override
  Widget build(BuildContext context) {
    if (initialCheck &&
        Provider.of<InventoryProvider>(context, listen: false)
            .unitTypes
            .isEmpty) {
      initialCheck = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditUnitType()),
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

  Scaffold mainBody(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: customTopSection(
                context: context,
                height: height,
                text: "Inventory",
                width: width,
                onTap: () {
                  _fetchData();
                }),
          ),
          inventoryAnalytics(context),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
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
                              builder: (context) => const UpdateInventory()),
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
                      isSelected: isEditing,
                      context: context,
                    ),
                    SizedBox(width: width),
                    textButton(
                      text: "Manage",
                      height: height,
                      width: width,
                      textColor:
                          Provider.of<InfoProvider>(context, listen: true)
                              .systemInfo
                              .iconsColor,
                      buttonColor:
                          Provider.of<InfoProvider>(context, listen: true)
                              .systemInfo
                              .iconsColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const EditUnitType()),
                        );
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: height * 2),
          tableSection(context),
        ],
      ),
    );
  }

  Container inventoryAnalytics(BuildContext context) {
    return Container(
      color: Provider.of<InfoProvider>(context, listen: true)
          .systemInfo
          .iconsColor
          .withOpacity(0.5),
      margin: EdgeInsets.symmetric(vertical: height * 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: height * 30,
      width: width * 100,
      child: Column(
        children: [
          buildCustomText(
              "Inventory Analytics", Data.darkTextColor, width * 2.2,
              fontWeight: FontWeight.bold),
          SizedBox(height: height),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              analyticsBox(context: context, count: 0, title: "Total Items"),
              analyticsBox(context: context, count: 0, title: "Low Stock"),
              analyticsBox(context: context, count: 0, title: "Out of Stock"),
              analyticsBox(
                  context: context,
                  count: 0,
                  title: "Inventory Worth",
                  isWorth: true),
            ],
          )
        ],
      ),
    );
  }

  Container analyticsBox({
    required BuildContext context,
    required int count,
    required String title,
    bool isWorth = false,
  }) {
    return Container(
      width: isWorth ? width * 20 : width * 15,
      height: height * 20,
      padding: EdgeInsets.symmetric(horizontal: width * 1.5),
      decoration: BoxDecoration(
        color: Provider.of<InfoProvider>(context, listen: true)
            .systemInfo
            .primaryColor,
        borderRadius: BorderRadius.circular(6.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25), // Shadow color
            spreadRadius: 0, // How much the shadow spreads
            blurRadius: 4, // How much the shadow blurs
            offset: const Offset(0, 5), // The offset of the shadow
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isWorth
            ? [
                buildCustomText(title, Colors.white, width * 1.65,
                    fontWeight: FontWeight.bold),
                SizedBox(
                  height: height,
                ),
                Row(
                  children: [
                    buildCustomText(
                        Provider.of<InfoProvider>(context, listen: true)
                            .systemInfo
                            .currencySymbol
                            .toString(),
                        Colors.white,
                        width * 3,
                        fontWeight: FontWeight.bold),
                    SizedBox(width: width),
                    buildCustomText(
                        count.toStringAsFixed(2), Colors.white, width * 3,
                        fontWeight: FontWeight.bold),
                  ],
                ),
              ]
            : [
                buildCustomText(count.toString(), Colors.white, width * 3,
                    fontWeight: FontWeight.bold),
                SizedBox(
                  height: height,
                ),
                buildCustomText(title, Colors.white, width * 1.65,
                    fontWeight: FontWeight.bold),
              ],
      ),
    );
  }

  Expanded tableSection(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SingleChildScrollView(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Provider.of<InventoryProvider>(context, listen: true)
                    .inventoryItems
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
                                tableTitle("Quantity Type", width),
                                tableTitle("Quantity", width),
                                tableTitle("Price", width),
                                tableTitle("Total", width),
                                tableTitle("Action", width),
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
                          decoration: const BoxDecoration(
                              color: Data.lightGreyBodyColor),
                          children: [
                            tableTitle("S.N.", width),
                            tableTitle("Name", width),
                            tableTitle("Quantity Type", width),
                            tableTitle("Quantity", width),
                            tableTitle("Price", width),
                            tableTitle("Total", width),
                            tableTitle("Action", width),
                          ]),
                      for (int index = 0;
                          index <
                              Provider.of<InventoryProvider>(context,
                                      listen: true)
                                  .inventoryItems
                                  .length;
                          index++)
                        buildInventoryRows(index),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  TableRow buildInventoryRows(int index) {
    return TableRow(
      decoration: const BoxDecoration(color: Data.lightGreyBodyColor),
      children: [
        tableItem((index + 1).toString(), width, context),
        InkWell(
          onTap: () {
            if (isEditing) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UpdateInventory(
                          isEdit: true,
                          index: index,
                          id: Provider.of<InventoryProvider>(context,
                                  listen: false)
                              .inventoryItems[index]
                              .id,
                        )),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              children: [
                tableItem(
                    Provider.of<InventoryProvider>(context, listen: true)
                        .inventoryItems[index]
                        .name,
                    width,
                    context),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
        tableItem(
            Provider.of<InventoryProvider>(context, listen: true)
                .inventoryItems[index]
                .type,
            width,
            context),
        tableItem(
            "x${Provider.of<InventoryProvider>(context, listen: true).inventoryItems[index].quantity.toString()}",
            width,
            context),
        tableItem(
            "${Provider.of<InfoProvider>(context, listen: true).systemInfo.currencySymbol} ${Provider.of<InventoryProvider>(context, listen: true).inventoryItems[index].price.toStringAsFixed(2)}",
            width,
            context),
        tableItem(
            "${Provider.of<InfoProvider>(context, listen: true).systemInfo.currencySymbol} ${(Provider.of<InventoryProvider>(context, listen: true).inventoryItems[index].price * Provider.of<InventoryProvider>(context, listen: true).inventoryItems[index].quantity).toStringAsFixed(2)}",
            width,
            context),
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
              bool isDeleted = await Provider.of<InventoryProvider>(context,
                      listen: false)
                  .deleteInventoryItem(
                      id: Provider.of<InventoryProvider>(context, listen: false)
                          .inventoryItems[index]
                          .id!,
                      index: index,
                      accessToken:
                          Provider.of<AuthProvider>(context, listen: false)
                              .user
                              .accessToken!,
                      context: context);
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
                      message: "Item could not be deleted.",
                    ),
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
