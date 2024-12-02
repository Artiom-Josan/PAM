import 'package:flutter/material.dart';

class WineCategoryCard extends StatelessWidget {
  final String imagePath;
  final String label;
  final String badgeCount;

  const WineCategoryCard({
    Key? key,
    required this.imagePath,
    required this.label,
    required this.badgeCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(imagePath, width: 100, height: 100),
        Text(label),
        Text(badgeCount),
      ],
    );
  }
}
