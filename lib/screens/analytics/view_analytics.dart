import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:epos_application/providers/user_provider.dart';
import 'package:epos_application/screens/employees/manage_employee.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ViewAnalytics extends StatefulWidget {
  const ViewAnalytics({super.key});

  @override
  State<ViewAnalytics> createState() => _ViewAnalyticsState();
}

class _ViewAnalyticsState extends State<ViewAnalytics> {
  bool init = true;
  late double height;
  late double width;
  bool isLoading = false;

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

  String filterDropDownValue = "Daily";
  List<String> filterDropDownList = ["Daily", "Weekly", "Monthly", "Yearly"];

  // Example data sets for the graph
  final Map<String, List<_ChartData>> graphData = {
    "Daily": [
      _ChartData('0h', 1),
      _ChartData('4h', 3),
      _ChartData('8h', 5),
      _ChartData('12h', 7),
      _ChartData('16h', 9),
      _ChartData('20h', 11),
    ],
    "Weekly": [
      _ChartData('Mon', 2),
      _ChartData('Tue', 4),
      _ChartData('Wed', 6),
      _ChartData('Thu', 8),
      _ChartData('Fri', 10),
      _ChartData('Sat', 12),
      _ChartData('Sun', 14),
    ],
    "Monthly": [
      _ChartData('Week 1', 1.5),
      _ChartData('Week 2', 3.5),
      _ChartData('Week 3', 5.5),
      _ChartData('Week 4', 7.5),
    ],
    "Yearly": [
      _ChartData('Jan', 2.5),
      _ChartData('Feb', 4.5),
      _ChartData('Mar', 6.5),
      _ChartData('Apr', 8.5),
      _ChartData('May', 10.5),
      _ChartData('Jun', 12.5),
      _ChartData('Jul', 14.5),
      _ChartData('Aug', 16.5),
      _ChartData('Sep', 18.5),
      _ChartData('Oct', 20.5),
      _ChartData('Nov', 22.5),
      _ChartData('Dec', 24.5),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: topSection(
                context: context,
                height: height,
                text: "Analytics",
                width: width,
              ),
            ),
            employeeAnalytics(context),
            salesAnalytics(context),
          ],
        ),
      ),
    );
  }

  Column salesAnalytics(BuildContext context) {
    return Column(
      children: [
        buildCustomText("Sales Data", Data.darkTextColor, width * 2.2,
            fontWeight: FontWeight.bold),
        SizedBox(height: height),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                  height: height * 70,
                  width: width * 50,
                  padding: EdgeInsets.symmetric(
                      horizontal: width * 2, vertical: height),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(
                      color: Colors.black,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          buildCustomText("Revenue Overview",
                              Data.darkTextColor, width * 2.2,
                              fontWeight: FontWeight.bold),
                          SizedBox(height: height),
                        ],
                      ),
                      Expanded(
                        child: SfCartesianChart(
                          primaryXAxis: const CategoryAxis(),
                          primaryYAxis: NumericAxis(
                            axisLabelFormatter:
                                (AxisLabelRenderDetails details) {
                              return ChartAxisLabel(
                                  '£${details.value}', const TextStyle());
                            },
                          ),
                          title: const ChartTitle(text: 'Sales Analysis'),
                          legend: const Legend(isVisible: true),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: <CartesianSeries<dynamic, dynamic>>[
                            LineSeries<_ChartData, String>(
                              dataSource: graphData[filterDropDownValue]!,
                              xValueMapper: (_ChartData data, _) => data.x,
                              yValueMapper: (_ChartData data, _) => data.y,
                              name: 'Sales',
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                                labelAlignment: ChartDataLabelAlignment
                                    .top, // Adjust label position
                                textStyle: TextStyle(
                                    fontSize: 10, color: Colors.black),
                              ),
                              markerSettings:
                                  const MarkerSettings(isVisible: true),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: width * 18,
                                child: buildCustomText("Total Revenue",
                                    Data.darkTextColor, width * 2,
                                    fontWeight: FontWeight.bold),
                              ),
                              buildCustomText(
                                  "${Provider.of<InfoProvider>(context, listen: true).systemInfo.currencySymbol} 10000",
                                  Data.lightGreyTextColor,
                                  width * 2),
                            ],
                          ),
                          SizedBox(height: height),
                          Row(
                            children: [
                              SizedBox(
                                width: width * 18,
                                child: buildCustomText(
                                    "Average ($filterDropDownValue)",
                                    Data.darkTextColor,
                                    width * 2,
                                    fontWeight: FontWeight.bold),
                              ),
                              buildCustomText(
                                  "${Provider.of<InfoProvider>(context, listen: true).systemInfo.currencySymbol} 10000",
                                  Data.lightGreyTextColor,
                                  width * 2),
                            ],
                          ),
                        ],
                      ),
                    ],
                  )),
              Column(
                children: [
                  Container(
                    height: height * 10,
                    width: width * 40,
                    padding: EdgeInsets.symmetric(horizontal: width * 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.0),
                      border: Border.all(
                        color: Colors.black,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildCustomText(
                          "Filter",
                          Data.darkTextColor,
                          width * 2.2,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(
                          height: height * 8,
                          width: width * 20,
                          child: DropdownButtonFormField<String>(
                            // Remove padding to ensure text fits
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                                Icons.arrow_drop_down_circle_outlined),
                            iconSize: width * 2.5,
                            iconDisabledColor:
                                Provider.of<InfoProvider>(context, listen: true)
                                    .systemInfo
                                    .iconsColor,
                            iconEnabledColor:
                                Provider.of<InfoProvider>(context, listen: true)
                                    .systemInfo
                                    .iconsColor,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: width * 1), // Adjust padding here
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Data
                                      .lightGreyBodyColor, // Custom focused border color
                                  width:
                                      1, // Custom focused border width (optional)
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Provider.of<InfoProvider>(context,
                                          listen: true)
                                      .systemInfo
                                      .primaryColor, // Custom focused border color
                                  width:
                                      2.0, // Custom focused border width (optional)
                                ),
                              ),
                            ),
                            hint: buildCustomText(
                              "Select",
                              Data.lightGreyTextColor,
                              width * 1.75,
                            ),
                            style: TextStyle(
                              color: Data.darkTextColor,
                              fontSize: width * 1.75,
                            ),
                            dropdownColor: Colors.white,
                            value: filterDropDownValue,
                            onChanged: (String? newValue) {
                              setState(() {
                                filterDropDownValue = newValue!;
                              });
                            },
                            items: filterDropDownList
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height),
                  Container(
                      height: height * 20,
                      width: width * 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(
                          color: Colors.black,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildCustomText("Top Selling Items",
                              Data.darkTextColor, width * 2.2,
                              fontWeight: FontWeight.bold),
                          SizedBox(height: height),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  buildCustomText("1. Product A",
                                      Data.darkTextColor, width * 2),
                                  buildCustomText("Rs 1000",
                                      Data.lightGreyTextColor, width * 2),
                                ],
                              ),
                              Column(
                                children: [
                                  buildCustomText("2. Product B",
                                      Data.darkTextColor, width * 2),
                                  buildCustomText("Rs 1000",
                                      Data.lightGreyTextColor, width * 2),
                                ],
                              ),
                              Column(
                                children: [
                                  buildCustomText("3. Product C",
                                      Data.darkTextColor, width * 2),
                                  buildCustomText("Rs 1000",
                                      Data.lightGreyTextColor, width * 2),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )),
                  SizedBox(height: height),
                  Container(
                      height: height * 38,
                      width: width * 40,
                      padding: EdgeInsets.symmetric(horizontal: width * 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(
                          color: Colors.black,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: height),
                          buildCustomText("Sales By Category",
                              Data.darkTextColor, width * 2.2,
                              fontWeight: FontWeight.bold),
                          SizedBox(height: height),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildCustomText(
                                  "1. Food", Data.darkTextColor, width * 2),
                              buildCustomText("Rs 1000",
                                  Data.lightGreyTextColor, width * 2),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildCustomText(
                                  "2. Drinks", Data.darkTextColor, width * 2),
                              buildCustomText("Rs 1000",
                                  Data.lightGreyTextColor, width * 2),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildCustomText(
                                  "3. Food", Data.darkTextColor, width * 2),
                              buildCustomText("Rs 1000",
                                  Data.lightGreyTextColor, width * 2),
                            ],
                          ),
                        ],
                      )),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Container employeeAnalytics(BuildContext context) {
    return Container(
      color: Provider.of<InfoProvider>(context, listen: true)
          .systemInfo
          .iconsColor
          .withOpacity(0.5),
      margin: EdgeInsets.symmetric(vertical: height * 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: height * 30,
      child: Column(
        children: [
          buildCustomText("Employee Data", Data.darkTextColor, width * 2.2,
              fontWeight: FontWeight.bold),
          SizedBox(height: height),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              analyticsBox(
                title: "Total Employees",
                count: Provider.of<UserProvider>(context, listen: true)
                    .userList
                    .length,
                context: context,
                isTotal: true,
              ),
              analyticsBox(
                title: "Active Employees",
                count: Provider.of<UserProvider>(context, listen: true)
                    .userList
                    .where((user) => !user.isBlocked)
                    .length,
                context: context,
              ),
              genderBox(context: context),
              topEmployeeBox(context: context),
            ],
          ),
        ],
      ),
    );
  }

  Container analyticsBox({
    required BuildContext context,
    required int count,
    required String title,
    bool isTotal = false,
  }) {
    return Container(
      width: width * 15,
      height: height * 20,
      padding: EdgeInsets.symmetric(horizontal: width),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildCustomText(count.toString(), Colors.white, width * 3,
                  fontWeight: FontWeight.bold),
              isTotal
                  ? InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ManageEmployee()),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.remove_red_eye,
                              color: Colors.white, size: width * 1.5),
                          SizedBox(width: width * 0.2),
                          buildCustomText("View", Colors.white, width * 1.5),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
          SizedBox(
            height: height,
          ),
          buildCustomText(title, Colors.white, width * 1.65,
              fontWeight: FontWeight.bold),
        ],
      ),
    );
  }

  Container topEmployeeBox({
    required BuildContext context,
  }) {
    return Container(
      width: width * 20,
      height: height * 20,
      padding: EdgeInsets.symmetric(horizontal: width),
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
        children: [
          buildCustomText(
              "Top Employee($filterDropDownValue)", Colors.white, width * 1.7,
              fontWeight: FontWeight.bold),
          SizedBox(
            height: height,
          ),
          buildCustomText("Mr Shusandesh G C", Colors.white, width * 1.65),
        ],
      ),
    );
  }

  Container genderBox({
    required BuildContext context,
  }) {
    return Container(
      width: width * 32,
      height: height * 20,
      padding: EdgeInsets.symmetric(horizontal: width),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Icon(Icons.man, color: Colors.white, size: width * 6.5),
              buildCustomText(
                  Provider.of<UserProvider>(context, listen: true)
                      .userList
                      .where((user) => user.gender == "Male")
                      .length
                      .toString(),
                  Colors.white,
                  width * 3,
                  fontWeight: FontWeight.bold),
              SizedBox(width: width),
            ],
          ),
          Container(height: height * 15, width: 1.5, color: Colors.white),
          Row(
            children: [
              Icon(Icons.woman, color: Colors.white, size: width * 6.5),
              buildCustomText(
                  Provider.of<UserProvider>(context, listen: true)
                      .userList
                      .where((user) => user.gender == "Female")
                      .length
                      .toString(),
                  Colors.white,
                  width * 3,
                  fontWeight: FontWeight.bold),
              SizedBox(width: width),
            ],
          ),
          Container(height: height * 15, width: 1.5, color: Colors.white),
          Row(
            children: [
              SizedBox(width: width),
              buildCustomText("Others", Colors.white, width * 2,
                  fontWeight: FontWeight.bold),
              SizedBox(width: width),
              buildCustomText(
                  Provider.of<UserProvider>(context, listen: true)
                      .userList
                      .where((user) => user.gender == "Others")
                      .length
                      .toString(),
                  Colors.white,
                  width * 3,
                  fontWeight: FontWeight.bold),
              SizedBox(width: width),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final String x;
  final double y;
}
