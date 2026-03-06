import 'package:collaborative_knowledge_board/features/board_member/domain/entities/board_member.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BoardMemberWidget extends StatelessWidget {
  final BoardMember member;

  const BoardMemberWidget({
    super.key,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            member.userId,
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