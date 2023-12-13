import 'package:flutter/material.dart';

class CustomFadingWidget extends StatefulWidget {
  final Widget child;
  const CustomFadingWidget({super.key, required this.child});

  @override
  State<CustomFadingWidget> createState() => _CustomFadingWidgetState();
}

class _CustomFadingWidgetState extends State<CustomFadingWidget>
    with SingleTickerProviderStateMixin {
  late Animation _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation =
        Tween<double>(begin: 0.2, end: 0.8).animate(_animationController);
    _animationController.addListener(() {
      setState(() {
        // The state that has changed here is the animation object's value.
      });
    });
    _animationController.repeat(reverse: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: _animation.value, child: widget.child);
  }
}
