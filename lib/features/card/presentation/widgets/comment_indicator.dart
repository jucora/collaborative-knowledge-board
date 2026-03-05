import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommentIndicator extends StatelessWidget {
  final int count;

  const CommentIndicator({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.comment, size: 16),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}