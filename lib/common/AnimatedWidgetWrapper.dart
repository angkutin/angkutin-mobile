import 'package:flutter/material.dart';

class AnimatedWidgetWrapper extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const AnimatedWidgetWrapper({
    Key? key,
    required this.child,
    this.delay = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  _AnimatedWidgetWrapperState createState() => _AnimatedWidgetWrapperState();
}

class _AnimatedWidgetWrapperState extends State<AnimatedWidgetWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Start the animation after a short delay
    Future.delayed(widget.delay, () {
      setState(() {
        _visible = true;
      });
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 800),
        child: widget.child,
      ),
    );
  }
}
