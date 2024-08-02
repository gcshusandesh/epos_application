import 'dart:async';

import 'package:epos_application/components/size_config.dart';
import 'package:flutter/material.dart';

class RecommendationsUI extends StatefulWidget {
  const RecommendationsUI({super.key, required this.recommendations});
  final List<String> recommendations;

  @override
  State<RecommendationsUI> createState() => _RecommendationsUIState();
}

class _RecommendationsUIState extends State<RecommendationsUI>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  double _scrollPosition = 0.0;
  bool _isUserScrolling = false;
  bool init = true;
  late double height;
  late double width;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _startAutoScroll();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 1.05).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (init) {
      SizeConfig().init(context);
      height = SizeConfig.safeBlockVertical;
      width = SizeConfig.safeBlockHorizontal;
      init = false;
    }
  }

  void _onScroll() {
    if (_scrollController.position.isScrollingNotifier.value) {
      _isUserScrolling = true;
      _timer?.cancel();
    } else {
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Steel Blue to Light Steel Blue gradient
    Color boxColor1 = const Color(0xFF4682B4); // Steel Blue
    Color boxColor2 = const Color(0xFFB0C4DE); // Light Steel Blue

    Gradient gradient = LinearGradient(
      colors: [boxColor1, boxColor2],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return SizedBox(
      height: height * 10,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.recommendations.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(
                  horizontal: width * 1.5, vertical: height * 0.5),
              padding: EdgeInsets.symmetric(
                horizontal: width * 2,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6.0,
                    offset: const Offset(0, 4),
                  ),
                ],
                gradient: gradient,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                      horizontal: width * 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Top Selling',
                      style: TextStyle(
                        fontSize: width * 1.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
