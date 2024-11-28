// lib/widgets/custom_filter_button.dart
import 'package:flutter/material.dart';

class CustomFilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;

  const CustomFilterButton({
    Key? key,
    required this.label,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isSelected ? Colors.red[100] : Colors.grey[200],
        border: Border.all(color: isSelected ? Colors.red : Colors.grey, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.red : Colors.grey[700],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
