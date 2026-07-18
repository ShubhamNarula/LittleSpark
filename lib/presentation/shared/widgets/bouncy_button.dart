import 'package:flutter/material.dart';

class BouncyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const BouncyButton({
    Key? key,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  @override
  State<BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<BouncyButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _scale = 0.93;
        });
      },
      onTapUp: (_) {
        setState(() {
          _scale = 1.0;
        });
        // Optional slight delay to let the scale animation finish bounce back
        Future.delayed(const Duration(milliseconds: 80), () {
          if (mounted) {
            widget.onTap();
          }
        });
      },
      onTapCancel: () {
        setState(() {
          _scale = 1.0;
        });
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
