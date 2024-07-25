import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:epos_application/providers/order_provider.dart';
import 'package:epos_application/screens/payment/invoice_pdf.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Payment extends StatefulWidget {
  const Payment({
    super.key,
    this.isSales = false,
  });
  final bool isSales;

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  bool init = true;
  late double height;
  late double width;
  bool isEditing = false;
  bool isLoading = false;

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

  void _fetchData() {
    //fetch data from api
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        mainBody(context),
      ],
    );
  }

  Scaffold mainBody(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            topSection(
                context: context,
                text: widget.isSales ? "Sales History" : "Payment",
                height: height,
                width: width),
            SizedBox(height: height * 2),
            editSection(),
            SizedBox(height: height * 2),
            tableSection(context),
          ],
        ),
      ),
    );
  }

  Expanded tableSection(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Provider.of<OrderProvider>(context, listen: true)
                  .processedOrders
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
                            children: widget.isSales
                                ? [
                                    tableTitle("S.N.", width),
                                    tableTitle("Order ID", width),
                                    tableTitle("Table Number", width),
                                    tableTitle("Items", width),
                                    tableTitle("Price", width),
                                    tableTitle("Timestamp", width),
                                    tableTitle("Action", width),
                                  ]
                                : [
                                    tableTitle("S.N.", width),
                                    tableTitle("Order ID", width),
                                    tableTitle("Table Number", width),
                                    tableTitle("Items", width),
                                    tableTitle("Price", width),
                                    tableTitle("Adjusted Price", width),
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
                            width * 1.5,
                          ),
                        ),
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
                        children: widget.isSales
                            ? [
                                tableTitle("S.N.", width),
                                tableTitle("Order ID", width),
                                tableTitle("Table Number", width),
                                tableTitle("Items", width),
                                tableTitle("Price", width),
                                tableTitle("Timestamp", width),
                                tableTitle("Action", width),
                              ]
                            : [
                                tableTitle("S.N.", width),
                                tableTitle("Order ID", width),
                                tableTitle("Table Number", width),
                                tableTitle("Items", width),
                                tableTitle("Price", width),
                                tableTitle("Adjusted Price", width),
                                tableTitle("Action", width),
                              ]),
                    for (int index = 0;
                        index <
                            Provider.of<OrderProvider>(context, listen: true)
                                .processedOrders
                                .length;
                        index++)
                      buildPaymentRow(
                          index: index,
                          order:
                              Provider.of<OrderProvider>(context, listen: true)
                                  .processedOrders[index]),
                  ],
                ),
        ),
      ),
    );
  }

  //

  TableRow buildPaymentRow(
      {required int index, required ProcessedOrder order}) {
    if (widget.isSales && order.status == OrderStatus.served && order.isPaid) {
      // Display only served and paid items in Sales History
      return TableRow(
        decoration: const BoxDecoration(color: Data.lightGreyBodyColor),
        children: [
          tableItem((index + 1).toString(), width, context),
          tableItem("#${order.id}", width, context),
          tableItem(order.tableNumber, width, context),
          tableItem(order.items, width, context),
          tableItem("£${order.price.toStringAsFixed(2)}", width, context),
          tableItem(
              "£${order.adjustedPrice.toStringAsFixed(2)}", width, context),
          Padding(
            padding: EdgeInsets.symmetric(vertical: height, horizontal: width),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                textButton(
                  text: "View",
                  height: height,
                  width: width,
                  textColor: Provider.of<InfoProvider>(context, listen: true)
                      .systemInfo
                      .primaryColor,
                  buttonColor: Provider.of<InfoProvider>(context, listen: true)
                      .systemInfo
                      .primaryColor,
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });
                    await generateInvoicePdf(
                        context: context,
                        order: order,
                        currency:
                            Provider.of<InfoProvider>(context, listen: false)
                                .systemInfo
                                .currencySymbol!);
                    setState(() {
                      isLoading = false;
                    });
                  },
                ),
                SizedBox(width: width),
                textButton(
                  text: "Send",
                  height: height,
                  width: width,
                  textColor: Provider.of<InfoProvider>(context, listen: true)
                      .systemInfo
                      .primaryColor,
                  buttonColor: Provider.of<InfoProvider>(context, listen: true)
                      .systemInfo
                      .primaryColor,
                  onTap: () async {},
                )
              ],
            ),
          ),
        ],
      );
    } else if (!widget.isSales &&
        order.status == OrderStatus.served &&
        !order.isPaid) {
      // Display only served but unpaid items in normal Payment page
      return TableRow(
        decoration: const BoxDecoration(color: Data.lightGreyBodyColor),
        children: [
          tableItem((index + 1).toString(), width, context),
          tableItem("#${order.id}", width, context),
          tableItem(order.tableNumber, width, context),
          tableItem(order.items, width, context),
          tableItem("£${order.price.toStringAsFixed(2)}", width, context),
          tableItem(
              "£${order.adjustedPrice.toStringAsFixed(2)}", width, context),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: width * 3, vertical: height),
            child: textButton(
              text: "Pay",
              height: height,
              width: width,
              textColor: Provider.of<InfoProvider>(context, listen: true)
                  .systemInfo
                  .primaryColor,
              buttonColor: Provider.of<InfoProvider>(context, listen: true)
                  .systemInfo
                  .primaryColor,
              onTap: () async {},
            ),
          ),
        ],
      );
    } else {
      // Return an empty TableRow if the order does not meet the conditions
      return const TableRow(children: [
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
        SizedBox(),
      ]);
    }
  }

  Widget tableTitle(String text, double width) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 5),
      child: buildBodyText(
        text,
        Data.lightGreyTextColor,
        width,
        fontFamily: "RobotoMedium",
      ),
    ));
  }

  Row editSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        iconButton(
          isSvg: false,
          "",
          icon: Icons.refresh,
          height,
          width,
          () {
            _fetchData();
          },
          context: context,
        ),
        // widget.isSales
        //     ? Row(
        //         children: [
        //           SizedBox(width: width),
        //           textButton(
        //               text: "Export",
        //               height: height,
        //               width: width,
        //               textColor:
        //                   Provider.of<InfoProvider>(context, listen: true)
        //                       .systemInfo
        //                       .primaryColor,
        //               buttonColor:
        //                   Provider.of<InfoProvider>(context, listen: true)
        //                       .systemInfo
        //                       .primaryColor,
        //               onTap: () {}),
        //         ],
        //       )
        //     : const SizedBox(),
      ],
    );
  }
}
