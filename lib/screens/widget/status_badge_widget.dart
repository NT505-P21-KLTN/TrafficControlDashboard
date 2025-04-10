import 'package:flutter/material.dart';

class StatusBadgeWidget extends StatelessWidget {
  final String status;

  const StatusBadgeWidget({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color textColor;
    
    switch (status.toLowerCase()) {
      case 'training':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        break;
      case 'simulating':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'terminated':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        break;
      case 'idle':
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
        break;
      default:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}