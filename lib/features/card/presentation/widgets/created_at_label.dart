import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CreatedAtLabel extends StatelessWidget {
  final DateTime date;

  const CreatedAtLabel({required this.date});

  @override
  Widget build(BuildContext context) {
    final formatted =
        "${date.day}/${date.month}/${date.year}";

    return Row(
      children: [
        const Icon(Icons.schedule, size: 16),
        const SizedBox(width: 4),
        Text(
          formatted,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}