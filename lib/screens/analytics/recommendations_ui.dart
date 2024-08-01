import 'dart:async';

import 'package:epos_application/components/size_config.dart';
import 'package:flutter/material.dart';

class RecommendationsUI extends StatefulWidget {
  const RecommendationsUI({super.key, required this.recommendations});
  final List<String> recommendations;

  @override
  State<RecommendationsUI> createState() => _RecommendationsUIState();
}

class _RecommendationsUIState extends State<RecommendationsUI> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  double _scrollPosition = 0.0;
  bool _isUserScrolling = false;
  bool init = true;
  late double height;
  late double width;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _startAutoScroll();
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

  void _onScroll() {
    if (_scrollController.position.isScrollingNotifier.value) {
      // User is scrolling
      _isUserScrolling = true;
      _timer?.cancel();
    } else {
      // User has stopped scrolling
      if (_isUserScrolling) {
        _isUserScrolling = false;
        _startAutoScroll();
      }
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
    _timer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.recommendations.length,
        itemBuilder: (context, index) {
          return Container(
            // width: width * 20,
            margin:
                EdgeInsets.symmetric(horizontal: width, vertical: height * 0.5),
            padding: EdgeInsets.symmetric(
                horizontal: width * 2, vertical: height * 0.5),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8.0,
                  offset: const Offset(0, 4),
                ),
              ],
              gradient: const LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Center(
                  child: Text(
                    widget.recommendations[index],
                    style: TextStyle(
                      fontSize: width * 2.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    'Top Selling',
                    style: TextStyle(
                      fontSize: width * 1.25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
