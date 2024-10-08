import 'package:epos_application/components/common_widgets.dart';
import 'package:epos_application/components/data.dart';
import 'package:epos_application/components/models.dart';
import 'package:epos_application/components/size_config.dart';
import 'package:epos_application/providers/auth_provider.dart';
import 'package:epos_application/providers/info_provider.dart';
import 'package:epos_application/providers/menu_provider.dart';
import 'package:epos_application/providers/order_provider.dart';
import 'package:epos_application/providers/user_provider.dart';
import 'package:epos_application/screens/employees/manage_employee.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  void initState() {
    super.initState();
    _fetchData();
  }

  _fetchData({bool reload = false}) async {
    setState(() {
      isLoading = true;
    });
    if (reload) {
      await Provider.of<UserProvider>(context, listen: false).getUserList(
        context: context,
        user: Provider.of<AuthProvider>(context, listen: false).user,
      );
    }
    if (mounted) {
      await Provider.of<OrderProvider>(context, listen: false).getOrders(
        context: context,
        accessToken:
            Provider.of<AuthProvider>(context, listen: false).user.accessToken!,
      );
    }
    if (mounted) {
      await Provider.of<MenuProvider>(context, listen: false).getMenuList(
        context: context,
        accessToken:
            Provider.of<AuthProvider>(context, listen: false).user.accessToken!,
        isCategory: true,
      );
    }
    if (mounted) {
      await Provider.of<MenuProvider>(context, listen: false).getMenuList(
        context: context,
        accessToken:
            Provider.of<AuthProvider>(context, listen: false).user.accessToken!,
        isItem: true,
      );
    }
    calculateData();
    setState(() {
      isLoading = false;
    });
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

  String filterDropDownValue = "Daily";
  List<String> filterDropDownList = ["Daily", "Weekly", "Monthly", "Yearly"];

  String? topEmployee;

  void calculateData() {
    setState(() {
      // Get date range based on filter
      DateTimeRange dateRange = getDateRange(filterDropDownValue);
      if (Provider.of<OrderProvider>(context, listen: false)
          .processedOrders
          .isNotEmpty) {
        List<ProcessedOrder> paidOrders =
            Provider.of<OrderProvider>(context, listen: false)
                .processedOrders
                .where((element) => element.isPaid)
                .toList();

        topEmployee = extractTopEmployee(
          paidOrders: paidOrders,
          startDate: dateRange.start,
          endDate: dateRange.end,
        );

        totalRevenue = calculateTotalRevenue(
          paidOrders: paidOrders,
        );

        filteredRevenue = calculateFilteredRevenue(
          paidOrders: paidOrders,
          startDate: dateRange.start,
          endDate: dateRange.end,
        );

        totalMargin = calculateTotalMargin(
          paidOrders: paidOrders,
        );

        filteredMargin = calculateFilteredMargin(
          paidOrders: paidOrders,
          startDate: dateRange.start,
          endDate: dateRange.end,
        );

        // Extract top selling items based on the selected date range
        topSellingItems = extractTopSellingItems(
          paidOrders,
          dateRange.start,
          dateRange.end,
          Provider.of<MenuProvider>(context, listen: false).priceList,
        );

        salesByCategory = calculateSalesByCategory(
          menuItemsByCategory: Provider.of<MenuProvider>(context, listen: false)
              .menuItemsByCategory,
          paidOrders: paidOrders,
          priceList:
              Provider.of<MenuProvider>(context, listen: false).priceList,
          startDate: dateRange.start,
          endDate: dateRange.end,
        );
      }
    });
  }

  String extractTopEmployee({
    required List<ProcessedOrder> paidOrders,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    // A map to hold employee rating data
    Map<String, EmployeeRating> employeeRatingMap = {};

    // Filter orders based on date range
    List<ProcessedOrder> filteredOrders = paidOrders.where((order) {
      DateTime orderDate = order.orderDateTime!;
      return orderDate.isAfter(startDate) && orderDate.isBefore(endDate);
    }).toList();

    // Aggregate ratings data
    for (var order in filteredOrders) {
      var employeeName = order.receivedBy;
      var rating = order.rating;

      if (employeeName != null) {
        if (employeeRatingMap.containsKey(employeeName)) {
          // If the employee already exists in the employeeRatingMap, their rating is updated by calling addRating(rating).
          employeeRatingMap[employeeName]!.addRating(rating);
        } else {
          // If the employee does not exist in the map, a new EmployeeRating object is created and added to the map.
          // Initialize with 0 if rating is 0
          employeeRatingMap[employeeName] = EmployeeRating(
            employeeName: employeeName,
            ratingCount: rating != 0
                ? 1
                : 0, // Initialize with 1 only if rating is not 0
            totalRating: rating != 0
                ? rating
                : 0, // Initialize with rating only if it's not 0
          );
        }
      }
    }

    // Convert the map to a list and sort by average rating in descending order
    var sortedEmployees = employeeRatingMap.values.toList()
      ..sort((a, b) => b.averageRating.compareTo(a.averageRating));

    if (sortedEmployees.isEmpty || sortedEmployees[0].averageRating == 0) {
      return "No Data Available";
    }
    return sortedEmployees[0].employeeName;
  }

  double filteredRevenue = 0;

  double calculateFilteredRevenue({
    required List<ProcessedOrder> paidOrders,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    // Initialize total revenue
    double filteredRevenue = 0.0;

    // Aggregate revenue data within the specified date range and for paid orders
    for (var order in paidOrders) {
      if (order.isPaid) {
        DateTime orderDate = order.orderDateTime!;

        if (orderDate.isAfter(startDate) && orderDate.isBefore(endDate)) {
          filteredRevenue += (order.price - order.discount);
        }
      }
    }

    return filteredRevenue;
  }

  double filteredMargin = 0;
  double calculateFilteredMargin({
    required List<ProcessedOrder> paidOrders,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    // Initialize total margin
    double filteredMargin = 0.0;

    // Aggregate margin data within the specified date range and for paid orders
    for (var order in paidOrders) {
      if (order.isPaid) {
        DateTime orderDate = order.orderDateTime!;

        if (orderDate.isAfter(startDate) && orderDate.isBefore(endDate)) {
          double orderRevenue = order.price - order.discount;
          filteredMargin += (orderRevenue - order.cost);
        }
      }
    }

    return filteredMargin;
  }

  double totalRevenue = 0;
  double calculateTotalRevenue({
    required List<ProcessedOrder> paidOrders,
  }) {
    // Initialize total revenue
    double totalRevenue = 0.0;

    // Aggregate revenue data within the specified date range and for paid orders
    for (var order in paidOrders) {
      if (order.isPaid) {
        totalRevenue += (order.price - order.discount);
      }
    }

    return totalRevenue;
  }

  double totalMargin = 0;
  double calculateTotalMargin({
    required List<ProcessedOrder> paidOrders,
  }) {
    // Initialize total profit
    double totalMargin = 0.0;

    // Aggregate profit data within the specified date range and for paid orders
    for (var order in paidOrders) {
      if (order.isPaid) {
        double orderRevenue = order.price - order.discount;
        totalMargin += (orderRevenue - order.cost);
      }
    }

    return totalMargin;
  }

  Map<String, double> calculateSalesByCategory({
    required List<MenuItemsByCategory> menuItemsByCategory,
    required List<ProcessedOrder>
        paidOrders, // Assuming this list only contains paid orders
    required List<OrderItem> priceList,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    // Map for item names to categories
    Map<String, String> itemCategoryMap = {};

    // Map for item names to prices
    Map<String, double> itemPriceMap = {};

    // Populate itemCategoryMap
    for (var categoryGroup in menuItemsByCategory) {
      for (var item in categoryGroup.menuItems) {
        itemCategoryMap[item.name] = categoryGroup.category.name;
      }
    }

    // Populate itemPriceMap
    for (var orderItem in priceList) {
      itemPriceMap[orderItem.name] = orderItem.price;
    }

    // Map to accumulate sales by category
    Map<String, double> categorySalesMap = {};

    // Process each paid order
    for (var order in paidOrders) {
      DateTime orderDate = order.orderDateTime!;

      // Check if the order is within the date range
      if (orderDate.isAfter(startDate) && orderDate.isBefore(endDate)) {
        var itemsInOrder = order.items.split(', ');

        for (var item in itemsInOrder) {
          var parts = item.split(' x');
          if (parts.length == 2) {
            var itemName = parts[0].trim();
            var quantity = int.tryParse(parts[1].trim()) ?? 0;

            // Retrieve price and category for the item
            var itemPrice = itemPriceMap[itemName];
            var category = itemCategoryMap[itemName];

            if (itemPrice != null && category != null) {
              var totalAmount = itemPrice * quantity;

              // Accumulate the total sales for the category
              if (categorySalesMap.containsKey(category)) {
                categorySalesMap[category] =
                    categorySalesMap[category]! + totalAmount;
              } else {
                categorySalesMap[category] = totalAmount;
              }
            }
          }
        }
      }
    }

    // Sort the map by sales amount in descending order
    var sortedCategorySales = categorySalesMap.entries.toList()
      ..sort((e1, e2) => e2.value.compareTo(e1.value));

    // Convert sorted entries back to a map
    var sortedCategorySalesMap = {
      for (var entry in sortedCategorySales) entry.key: entry.value
    };

    // Return the sales amount by category
    return sortedCategorySalesMap;
  }

  List<ItemSales> extractTopSellingItems(
    List<ProcessedOrder> paidOrders,
    DateTime startDate,
    DateTime endDate,
    List<OrderItem> priceList, // Added parameter
  ) {
    // A map to hold item sales data
    Map<String, ItemSales> itemSalesMap = {};

    // Create a lookup map for item prices
    Map<String, double> itemPriceMap = {};
    for (var item in priceList) {
      itemPriceMap[item.name] = item.price;
    }

    List<ProcessedOrder> filteredOrder =
        paidOrders.where((element) => element.isPaid).toList();

    // Aggregate sales data
    for (var order in filteredOrder) {
      // Check if the order date falls within the specified range and is paid
      if (order.orderDateTime != null) {
        DateTime orderDate = order.orderDateTime!;

        if (orderDate.isAfter(startDate) &&
            orderDate.isBefore(endDate) &&
            order.isPaid) {
          // Split items string and process each item
          var items = order.items.split(', ');
          for (var item in items) {
            var parts = item.split(' x');
            if (parts.length == 2) {
              var itemName = parts[0].trim();
              var quantity = int.tryParse(parts[1].trim()) ?? 0;

              // Look up the price for the item
              var itemPrice =
                  itemPriceMap[itemName] ?? 0.0; // Default to 0.0 if not found
              var totalAmount = itemPrice * quantity;

              if (itemSalesMap.containsKey(itemName)) {
                itemSalesMap[itemName]!.addSale(quantity, totalAmount);
              } else {
                itemSalesMap[itemName] = ItemSales(
                  itemName: itemName,
                  quantity: quantity,
                  totalSalesAmount: totalAmount,
                );
              }
            }
          }
        }
      }
    }

    // Convert the map to a list and sort by total sales amount in descending order
    var sortedItems = itemSalesMap.values.toList()
      ..sort((a, b) => b.totalSalesAmount.compareTo(a.totalSalesAmount));
    // Get the top 3 selling items
    return sortedItems.take(3).toList();
  }

  DateTimeRange getDateRange(String filterType) {
    DateTime now = DateTime.now();

    switch (filterType) {
      case 'Daily':
        DateTime startOfDay = DateTime(now.year, now.month, now.day);
        DateTime endOfDay = startOfDay.add(const Duration(days: 1));
        return DateTimeRange(start: startOfDay, end: endOfDay);

      case 'Weekly':
        // Calculate days since Monday
        int daysToStartOfWeek = now.weekday - DateTime.monday;

        // Determine the start of the week (Monday at 00:00:00)
        DateTime startOfWeek = DateTime(
          now.year,
          now.month,
          now.day -
              daysToStartOfWeek, // Calculate the Monday of the current week
          0, 0, 0, // Set time to 00:00:00
        );

        // Determine the end of the week (Sunday at 23:59:59)
        DateTime endOfWeek = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day + 6, // Sunday is 6 days after Monday
          23, 59, 59, // Set time to 23:59:59
        );

        return DateTimeRange(start: startOfWeek, end: endOfWeek);

      case 'Monthly':
        DateTime startOfMonth = DateTime(now.year, now.month, 1);
        DateTime endOfMonth = DateTime(now.year, now.month + 1, 1)
            .subtract(const Duration(days: 1));
        return DateTimeRange(start: startOfMonth, end: endOfMonth);

      case 'Yearly':
        DateTime startOfYear = DateTime(now.year, 1, 1);
        DateTime endOfYear =
            DateTime(now.year + 1, 1, 1).subtract(const Duration(days: 1));
        return DateTimeRange(start: startOfYear, end: endOfYear);

      default:
        return DateTimeRange(start: now, end: now); // Default to current date
    }
  }

  List<ItemSales> topSellingItems = [];

  Map<String, double> salesByCategory = {};

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: customTopSection(
                  context: context,
                  height: height,
                  text: "Analytics",
                  width: width,
                  onTap: () {
                    _fetchData(reload: true);
                  }),
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
                          height: height * 6,
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
                                calculateData();
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
                  SalesByCategoryContainer(
                    categorySalesMap: salesByCategory,
                    height: height,
                    width: width,
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                      height: height * 35,
                      width: width * 40,
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
                              buildCustomText("Sales Financial Overview",
                                  Data.darkTextColor, width * 2.2,
                                  fontWeight: FontWeight.bold),
                            ],
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: width * 25,
                                    child: buildCustomText("Total Revenue",
                                        Data.darkTextColor, width * 2),
                                  ),
                                  buildCustomText(
                                      "${Provider.of<InfoProvider>(context, listen: true).systemInfo.currencySymbol} ${totalRevenue.toStringAsFixed(2)}",
                                      Data.lightGreyTextColor,
                                      width * 2),
                                ],
                              ),
                              SizedBox(height: height),
                              Row(
                                children: [
                                  SizedBox(
                                    width: width * 25,
                                    child: buildCustomText("Total Margins",
                                        Data.darkTextColor, width * 2),
                                  ),
                                  buildCustomText(
                                      "${Provider.of<InfoProvider>(context, listen: true).systemInfo.currencySymbol} ${totalMargin.toStringAsFixed(2)}",
                                      Data.lightGreyTextColor,
                                      width * 2),
                                ],
                              ),
                              SizedBox(height: height),
                              Container(
                                height: 1,
                                width: width * 36,
                                color: Colors.black,
                              ),
                              SizedBox(height: height),
                              Row(
                                children: [
                                  SizedBox(
                                    width: width * 25,
                                    child: buildCustomText(
                                        "Revenue ($filterDropDownValue)",
                                        Data.darkTextColor,
                                        width * 2),
                                  ),
                                  buildCustomText(
                                      "${Provider.of<InfoProvider>(context, listen: true).systemInfo.currencySymbol} ${filteredRevenue.toStringAsFixed(2)}",
                                      Data.lightGreyTextColor,
                                      width * 2),
                                ],
                              ),
                              SizedBox(height: height),
                              Row(
                                children: [
                                  SizedBox(
                                    width: width * 25,
                                    child: buildCustomText(
                                        "Margins ($filterDropDownValue)",
                                        Data.darkTextColor,
                                        width * 2),
                                  ),
                                  buildCustomText(
                                      "${Provider.of<InfoProvider>(context, listen: true).systemInfo.currencySymbol} ${filteredMargin.toStringAsFixed(2)}",
                                      Data.lightGreyTextColor,
                                      width * 2),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )),
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
                        buildCustomText(
                          "Top Selling Items",
                          Data.darkTextColor,
                          width * 2.2,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(height: height),
                        topSellingItems.isNotEmpty
                            ? Expanded(
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: topSellingItems.length,
                                  itemBuilder: (context, index) {
                                    final item = topSellingItems[index];
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: width * 1.5),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          buildCustomText(
                                            "${index + 1}. ${item.itemName}",
                                            Data.darkTextColor,
                                            width * 2,
                                          ),
                                          buildCustomText(
                                            "${Provider.of<InfoProvider>(context, listen: true).systemInfo.currencySymbol} ${item.totalSalesAmount.toStringAsFixed(2)}",
                                            Data.lightGreyTextColor,
                                            width * 2,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Center(
                                child: buildCustomText(
                                  "No data available",
                                  Data.darkTextColor,
                                  width * 2,
                                ),
                              ),
                      ],
                    ),
                  ),
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
          Provider.of<UserProvider>(context, listen: true)
                      .userList
                      .where((user) => user.userType.name == "waiter")
                      .length >
                  1
              ? Row(
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
                )
              : Row(
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
      width: width * 22,
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
              "Top Server($filterDropDownValue)", Colors.white, width * 1.7,
              fontWeight: FontWeight.bold),
          SizedBox(
            height: height,
          ),
          buildCustomText(
              topEmployee ?? "No Data Available", Colors.white, width * 1.65),
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
              SizedBox(width: width * 0.8),
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
              SizedBox(width: width * 0.8),
            ],
          ),
          Container(height: height * 15, width: 1.5, color: Colors.white),
          Row(
            children: [
              SizedBox(width: width * 0.8),
              buildCustomText("Others", Colors.white, width * 2,
                  fontWeight: FontWeight.bold),
              SizedBox(width: width * 0.8),
              buildCustomText(
                  Provider.of<UserProvider>(context, listen: true)
                      .userList
                      .where((user) => user.gender == "Others")
                      .length
                      .toString(),
                  Colors.white,
                  width * 3,
                  fontWeight: FontWeight.bold),
              SizedBox(width: width * 0.8),
            ],
          ),
        ],
      ),
    );
  }
}

class ItemSales {
  String itemName;
  int quantity;
  double totalSalesAmount;

  ItemSales({
    required this.itemName,
    this.quantity = 0,
    this.totalSalesAmount = 0.0,
  });

  void addSale(int qty, double amount) {
    quantity += qty;
    totalSalesAmount += amount;
  }
}

class SalesByCategoryContainer extends StatelessWidget {
  final Map<String, double> categorySalesMap;
  final double height;
  final double width;

  const SalesByCategoryContainer({
    super.key,
    required this.categorySalesMap,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    // Create a list of rows for each category and its sales amount
    List<Widget> salesRows =
        categorySalesMap.entries.toList().asMap().entries.map((entry) {
      int index = entry.key;
      var categoryEntry = entry.value;
      String category = categoryEntry.key;
      double totalAmount = categoryEntry.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildCustomText(
              "${index + 1}. $category", Data.darkTextColor, width * 2),
          buildCustomText(
              "${Provider.of<InfoProvider>(context, listen: true).systemInfo.currencySymbol} ${totalAmount.toStringAsFixed(2)}",
              Data.lightGreyTextColor,
              width * 2),
        ],
      );
    }).toList();

    return Container(
      height: height * 45,
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
          buildCustomText(
              "Sales By Category",
              Colors.black, // Assuming Data.darkTextColor
              width * 2.2,
              fontWeight: FontWeight.bold),
          SizedBox(height: height),
          categorySalesMap.isNotEmpty
              ? Expanded(
                  // Wrap in Expanded to make sure it takes available space
                  child: SingleChildScrollView(
                    child: Column(
                      children: salesRows, // Add rows inside this Column
                    ),
                  ),
                )
              : Center(
                  child: buildCustomText(
                    "No data available",
                    Data.darkTextColor,
                    width * 2,
                  ),
                ),
        ],
      ),
    );
  }
}

class EmployeeRating {
  final String employeeName;
  int ratingCount;
  double totalRating;

  EmployeeRating({
    required this.employeeName,
    required this.ratingCount,
    required this.totalRating,
  });

  double get averageRating => ratingCount == 0 ? 0 : totalRating / ratingCount;

  void addRating(double rating) {
    if (rating != 0) {
      totalRating += rating;
      ratingCount += 1;
    }
  }
}
