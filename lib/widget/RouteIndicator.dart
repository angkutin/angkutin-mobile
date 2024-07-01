import 'package:flutter/material.dart';

class RouteIndicator extends StatelessWidget {
  final Color color;
  final String message;
  const RouteIndicator({
    Key? key,
    required this.color,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(
          width: 5,
        ),
        Text(message)
      ],
    );
  }
}