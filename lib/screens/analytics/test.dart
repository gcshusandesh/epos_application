import 'dart:async';

import 'package:epos_application/components/size_config.dart';
import 'package:flutter/material.dart';

class AutoScrollingListScreen extends StatefulWidget {
  const AutoScrollingListScreen({super.key, required this.recommendations});
  final List<String> recommendations;

  @override
  State<AutoScrollingListScreen> createState() =>
      _AutoScrollingListScreenState();
}

class _AutoScrollingListScreenState extends State<AutoScrollingListScreen> {
  final ScrollController _scrollController = ScrollController();
  late Timer _timer;
  double _scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  bool init = true;
  late double height;
  late double width;

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

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double scrollAmount = 200.0;

      setState(() {
        if (_scrollPosition < maxScroll) {
          _scrollPosition += scrollAmount;
        } else {
          _scrollPosition = 0;
        }
        _scrollController.animateTo(
          _scrollPosition,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height * 2, // Adjust height to fit the bottom navigation bar
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.recommendations.length,
        itemBuilder: (context, index) {
          return Container(
            // width: width * 10, // Adjust width as needed
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            padding: EdgeInsets.symmetric(horizontal: width),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Text(
                widget.recommendations[index],
                style: TextStyle(
                  fontSize: width * 2,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}

class Recommendation {
  final String name;

  Recommendation({required this.name});
}
