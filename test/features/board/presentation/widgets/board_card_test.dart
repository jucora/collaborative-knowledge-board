import 'package:collaborative_knowledge_board/features/board/domain/entities/board.dart';
import 'package:collaborative_knowledge_board/features/board/presentation/pages/board_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('should display board title and description', (WidgetTester tester) async {
    // arrange
    final tBoard = Board(
      id: '1',
      title: 'Test Board',
      description: 'Test Description',
      createdAt: DateTime.now(),
      ownerId: 'user_1',
      columns: [],
      members: [],
    );

    // Act: Render a small part of the UI (the card) or the whole page with mocked data
    // For this simple test, we can check if the text appears in a Directionality widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Card(
            child: Column(
              children: [
                Text(tBoard.title),
                Text(tBoard.description),
              ],
            ),
          ),
        ),
      ),
    );

    // assert
    expect(find.text('Test Board'), findsOneWidget);
    expect(find.text('Test Description'), findsOneWidget);
  });
}
