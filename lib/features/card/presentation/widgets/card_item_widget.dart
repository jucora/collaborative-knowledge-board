import 'package:flutter/material.dart';
import '../../domain/entities/card_item.dart';
import 'comment_indicator.dart';
import 'created_at_label.dart';

class CardItemWidget extends StatelessWidget {
  final CardItem card;
  final VoidCallback? onTap;

  const CardItemWidget({
    super.key,
    required this.card,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TITLE
              Text(
                card.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              /// DESCRIPTION
              if (card.description.isNotEmpty)
                Text(
                  card.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),

              const SizedBox(height: 12),

              /// FOOTER (date + comments)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CreatedAtLabel(date: card.createdAt),
                  CommentIndicator(count: card.comments.length),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}