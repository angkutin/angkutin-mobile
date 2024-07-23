import 'package:flutter/material.dart';


class SmallTextGrey extends StatelessWidget {
  const SmallTextGrey({
    super.key,
    required this.description,
    this.style
  });

  final String description;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      style: style ?? const TextStyle(color: Colors.black54),
    );
  }
}
