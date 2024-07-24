import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:epos_application/providers/menu_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderTaker extends StatefulWidget {
  const OrderTaker({super.key});

  @override
  State<OrderTaker> createState() => _OrderTakerState();
}

class _OrderTakerState extends State<OrderTaker> {
  // Add any state variables you need here
  int itemCount = 3; // Example state variable

  bool init = true;
  late double height;
  late double width;
  TextEditingController tableNumberController = TextEditingController();
  TextEditingController specialInstructionController = TextEditingController();
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
    tableNumberController.dispose();
    specialInstructionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height * 60,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: height * 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildCustomText(
                    "                  ", Data.greyTextColor, width * 3),
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
                buildCustomText("Order ID: #3", Data.greyTextColor, width * 3,
                    fontWeight: FontWeight.bold),
              ],
            ),
            SizedBox(
              height: height,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    buildCustomText(
                        "Total Items Ordered: ${Provider.of<MenuProvider>(context, listen: true).totalCount}",
                        Data.greyTextColor,
                        width * 2.5),
                    buildCustomText(
                        "Total Amount:  £ ${Provider.of<MenuProvider>(context, listen: true).totalAmount.toStringAsFixed(2)}",
                        Data.greyTextColor,
                        width * 2.5),
                  ],
                ),
                Column(
                  children: [
                    dataBox(
                      title: "Table Number",
                      hintText: "Table Number",
                      isRequired: true,
                      controller: tableNumberController,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter a valid name!';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    textButton(
                      text: "Cancel",
                      height: height * 0.8,
                      width: width * 1.5,
                      textColor: Data.redColor,
                      buttonColor: Data.redColor,
                      onTap: () {},
                    ),
                    SizedBox(width: width * 2),
                    textButton(
                      text: "Confirm",
                      height: height * 0.8,
                      width: width * 1.5,
                      textColor:
                          Provider.of<InfoProvider>(context, listen: true)
                              .systemInfo
                              .primaryColor,
                      buttonColor:
                          Provider.of<InfoProvider>(context, listen: true)
                              .systemInfo
                              .primaryColor,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: height * 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                specialDataBox(
                  title: "Special Instructions",
                  hintText: "Special Instructions",
                  controller: specialInstructionController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter a valid name!';
                    }
                    return null;
                  },
                ),
              ],
            ),
            SizedBox(height: height),
            tableSection(context),
          ],
        ),
      ),
    );
  }

  Widget tableSection(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Provider.of<MenuProvider>(context, listen: true)
                    .order
                    .items
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
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: height),
                            child: buildSmallText(
                              "No Data Available",
                              Data.lightGreyTextColor,
                              width * 2,
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                : Column(
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
                                tableTitle("Quantity", width),
                                tableTitle("Price", width),
                                tableTitle("Action", width),
                              ]),
                          for (int index = 0;
                              index <
                                  Provider.of<MenuProvider>(context,
                                          listen: true)
                                      .order
                                      .items
                                      .length;
                              index++)
                            buildOrdersRow(
                              index: index,
                              item: Provider.of<MenuProvider>(context,
                                      listen: true)
                                  .order
                                  .items[index],
                            ),
                        ],
                      ),
                      Container(
                          height: height * 5,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Data.lightGreyBodyColor,
                            border: Border(
                              left: BorderSide(color: Colors.black, width: 1),
                              right: BorderSide(color: Colors.black, width: 1),
                              bottom: BorderSide(color: Colors.black, width: 1),
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                children: [
                                  buildCustomText(
                                      "Bill Amount: £ ${Provider.of<MenuProvider>(context, listen: true).totalAmount.toStringAsFixed(2)}",
                                      Data.greyTextColor,
                                      width * 2.5),
                                  buildCustomText(
                                      "(Inclusive 20% VAT @£${Provider.of<MenuProvider>(context, listen: true).vatAmount.toStringAsFixed(2)})",
                                      Data.greyTextColor,
                                      width * 2),
                                ],
                              ),
                              SizedBox(width: width * 5),
                            ],
                          )),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  TableRow buildOrdersRow({required int index, required OrderItem item}) {
    return TableRow(
      decoration: const BoxDecoration(color: Data.lightGreyBodyColor),
      children: [
        tableItem((index + 1).toString(), width),
        tableItem(item.name, width),
        tableItem(item.quantity.toString(), width),
        tableItem(item.price.toString(), width),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 5,
            vertical: height,
          ),
          child: textButton(
            text: "Delete",
            height: height * 0.6,
            width: width * 1.2,
            textColor: Data.redColor,
            buttonColor: Data.redColor,
            onTap: () async {},
          ),
        ),
      ],
    );
  }

  Container dataBox({
    required String title,
    required String hintText,
    required TextEditingController controller,
    required Function? validator,
    bool isRequired = false,
    bool isNumber = false,
  }) {
    return Container(
      width: width * 31,
      padding: EdgeInsets.symmetric(vertical: height, horizontal: width * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              buildCustomText(title, Data.lightGreyTextColor, width * 2.5,
                  fontFamily: "RobotoMedium"),
              isRequired
                  ? buildSmallText(
                      "*",
                      Data.redColor,
                      width * 2,
                    )
                  : const SizedBox(),
            ],
          ),
          SizedBox(height: height),
          Container(
            color: Colors.white,
            child: buildInputField(hintText, height, width, context, controller,
                validator: validator, isNumber: isNumber),
          ),
        ],
      ),
    );
  }

  Widget specialDataBox({
    required String title,
    required String hintText,
    required TextEditingController controller,
    required Function? validator,
    bool isRequired = false,
    bool isNumber = false,
    bool isSpecial = false,
  }) {
    return Row(
      children: [
        buildCustomText("$title:", Data.lightGreyTextColor, width * 3,
            fontFamily: "RobotoMedium"),
        isRequired
            ? buildSmallText(
                "*",
                Data.redColor,
                width * 2,
              )
            : const SizedBox(),
        SizedBox(
          width: width * 2,
        ),
        Container(
          color: Colors.white,
          child: buildInputField(hintText, height, width, context, controller,
              validator: validator, isNumber: isNumber),
        ),
      ],
    );
  }

  Widget tableTitle(String text, double width) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: buildBodyText(
        text,
        Data.lightGreyTextColor,
        width * 1.25,
        fontFamily: "RobotoMedium",
      ),
    ));
  }

  Widget tableItem(String text, double width) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: buildSmallText(
        text,
        Data.lightGreyTextColor,
        width * 1.75,
      ),
    ));
  }
}
