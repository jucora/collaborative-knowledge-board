class CardItem {
  final String id;
  final String columnId;
  final String title;
  final String description;
  final int position;
  final String createdBy;
  final DateTime createdAt;

  const CardItem({
    required this.id,
    required this.columnId,
    required this.title,
    required this.description,
    required this.position,
    required this.createdBy,
    required this.createdAt,
  });

  CardItem copyWith({
    String? id,
    String? columnId,
    String? title,
    String? description,
    int? position,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return CardItem(
      id: id ?? this.id,
      columnId: columnId ?? this.columnId,
      title: title ?? this.title,
      description: description ?? this.description,
      position: position ?? this.position,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}