import 'package:flutter/material.dart';

class RoomUsageCard extends StatelessWidget {
  final int percentage;
  final String label;
  final bool isSelected;

  const RoomUsageCard({
    super.key,
    required this.percentage,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade700 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$percentage%",
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 14,
            ),
          )
        ],
      ),
    );
  }
}
