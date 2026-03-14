import 'package:collaborative_knowledge_board/main.dart';
import 'package:collaborative_knowledge_board/core/storage/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorage extends Mock implements SecureStorageService {}

void main() {
  late MockSecureStorage mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockSecureStorage();
    when(() => mockSecureStorage.hasToken()).thenAnswer((_) async => false);
    when(() => mockSecureStorage.getToken()).thenAnswer((_) async => null);
    when(() => mockSecureStorage.saveToken(any())).thenAnswer((_) async => {});
  });

  testWidgets('Integration: Login and see boards from FakeDatabase', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStorageProvider.overrideWithValue(mockSecureStorage),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify we are on the Login Page
    expect(find.text('Welcome Back'), findsOneWidget);

    // Enter credentials
    await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
    await tester.enterText(find.byType(TextFormField).last, '123456');

    // Tap Login button
    await tester.tap(find.byType(ElevatedButton));
    
    // Sincronizar el mock justo después del tap
    when(() => mockSecureStorage.hasToken()).thenAnswer((_) async => true);

    // Wait for the login process and navigation
    await tester.pumpAndSettle();

    // Verify we are now on the Dashboard
    expect(find.text('My Boards'), findsOneWidget);
    
    // Check if at least one board card is rendered
    expect(find.byIcon(Icons.grid_view_rounded), findsWidgets);
  });
}
