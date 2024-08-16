import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:epos_application/providers/inventory_provider.dart';
import 'package:epos_application/screens/inventory/edit_unit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

      init = false;
    }
  }

  void _fetchData() async {
    setState(() {
      isLoading = true;
    });
    setState(() {
      isLoading = false;
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
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => const UpdateData(
                        //         isSpecial: true,
                        //       )),
                        // );
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
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: tableSection(context),
          ),
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
      child: SingleChildScrollView(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Provider.of<InventoryProvider>(context, listen: true)
                  .unitTypes
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
                              tableTitle("Item ID", width),
                              tableTitle("Name", width),
                              tableTitle("Quantity Type", width),
                              tableTitle("Quantity", width),
                              tableTitle("Price", width),
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
                        decoration:
                            const BoxDecoration(color: Data.lightGreyBodyColor),
                        children: [
                          tableTitle("S.N.", width),
                          tableTitle("Item ID", width),
                          tableTitle("Name", width),
                          tableTitle("Quantity Type", width),
                          tableTitle("Quantity", width),
                          tableTitle("Price", width),
                          tableTitle("Action", width),
                        ]),
                    // for (int index = 0;
                    // index <
                    //     Provider.of<InventoryProvider>(context, listen: true)
                    //         .unitTypes
                    //         .length;
                    // index++)
                    //   buildSpecialsRow(index),
                  ],
                ),
        ),
      ),
    );
  }
}
