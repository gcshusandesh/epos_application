import 'package:epos_application/components/buttons.dart';
import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/auth_provider.dart';
import 'package:epos_application/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  bool init = true;
  late double height;
  late double width;
  bool isEditing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });
    await Provider.of<OrderProvider>(context, listen: false).getOrders(
      accessToken:
          Provider.of<AuthProvider>(context, listen: false).user.accessToken!,
      context: context,
    );
    setState(() {
      isLoading = false;
    });
  }

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
                context: context, text: "Orders", height: height, width: width),
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
                            children: [
                              tableTitle("S.N.", width),
                              tableTitle("Order ID", width),
                              tableTitle("Table Number", width),
                              tableTitle("Items", width),
                              tableTitle("Instructions", width),
                              tableTitle("Price", width),
                              tableTitle("Timestamp", width),
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
                        children: [
                          tableTitle("S.N.", width),
                          tableTitle("Order ID", width),
                          tableTitle("Table Number", width),
                          tableTitle("Items", width),
                          tableTitle("Instructions", width),
                          tableTitle("Price", width),
                          tableTitle("Timestamp", width),
                          tableTitle("Status", width),
                        ]),
                    for (int index = 0;
                        index <
                            Provider.of<OrderProvider>(context, listen: true)
                                .processedOrders
                                .length;
                        index++)
                      buildOrdersRow(
                        index: index,
                        order: Provider.of<OrderProvider>(context, listen: true)
                            .processedOrders[index],
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  TableRow buildOrdersRow({required int index, required ProcessedOrder order}) {
    return TableRow(
      decoration: const BoxDecoration(color: Data.lightGreyBodyColor),
      children: [
        tableItem((index + 1).toString(), width, context),
        tableItem("#${order.id.toString()}", width, context),
        tableItem(order.tableNumber, width, context),
        tableItem(order.items, width, context),
        tableItem(order.instructions ?? "N/A", width, context),
        tableItem("£${order.price.toStringAsFixed(2)}", width, context),
        tableItem(order.timestamp, width, context),
        tableItem(order.status.name, width, context),
      ],
    );
  }

  Widget tableTitle(String text, double width) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15.0),
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
      ],
    );
  }
}
