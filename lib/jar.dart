import 'package:flutter/material.dart';

class Jar extends StatelessWidget {
  const Jar({
    super.key,
    required this.titleController,
    required this.blnc,
    required this.percentage,
    required this.onPercentageChanged,
    required this.onTitleChanged,
    required this.onRemove,
  });

  final TextEditingController titleController;
  final int blnc;
  final double percentage;
  final bool Function(double, bool) onPercentageChanged;
  final ValueChanged<String> onTitleChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    int balance = (blnc * percentage).round();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  controller: titleController,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  onChanged: onTitleChanged,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onRemove,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('${(percentage * 100).toStringAsFixed(0)}%'),
              Expanded(
                child: Slider(
                  value: percentage,
                  onChanged: (value) => onPercentageChanged(value, false),
                  onChangeEnd: (value) => onPercentageChanged(value, true),
                ),
              ),
              Text('$balance €'),
            ],
          ),
        ],
      ),
    );
  }
}