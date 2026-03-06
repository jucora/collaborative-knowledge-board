import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/board_column.dart';

class BoardColumnWidget extends StatelessWidget {
  final BoardColumn column;

  const BoardColumnWidget({
    super.key,
    required this.column,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            column.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 8),

          Expanded(
            child: ListView(
              children: const [],
            ),
          )
        ],
      ),
    );
  }
}