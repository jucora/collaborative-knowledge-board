import 'package:collaborative_knowledge_board/features/auth/domain/entities/auth_session.dart';
import 'package:collaborative_knowledge_board/features/auth/presentation/providers/auth_notifier.dart';
import 'package:collaborative_knowledge_board/features/auth/presentation/providers/auth_providers.dart';
import 'package:collaborative_knowledge_board/features/board/domain/entities/board.dart';
import 'package:collaborative_knowledge_board/features/board/presentation/providers/board_notifier.dart';
import 'package:collaborative_knowledge_board/main.dart';
import 'package:collaborative_knowledge_board/core/storage/secure_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSecureStorage extends Mock implements SecureStorageService {}

void main() {
  late MockSecureStorage mockSecureStorage;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock for shared_preferences to avoid MissingPluginException in tests
    const MethodChannel channel = MethodChannel('plugins.flutter.io/shared_preferences');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{};
      }
      return null;
    });

    await Supabase.initialize(
      url: 'https://fake.url.supabase.co',
      anonKey: 'fake_anon_key',
    );
  });

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
          // We override the auth notifier to avoid real Supabase calls during login
          authNotifierProvider.overrideWith(() => FakeAuthNotifier()),
          // We override the board notifier to return our test data
          boardNotifierProvider.overrideWith(() => FakeBoardNotifier()),
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
    
    // Update the mock to simulate a logged-in state after the tap
    when(() => mockSecureStorage.hasToken()).thenAnswer((_) async => true);
    when(() => mockSecureStorage.getToken()).thenAnswer((_) async => 'fake_token');

    // Wait for the login process and navigation
    await tester.pumpAndSettle();

    // Verify we are now on the Dashboard
    // Since we are not initializing Supabase auth state, 
    // it will likely fall into the "Shared with Me" tab if it matches logic.
    // However, let's just check if the Workspace title (part of AppBar) is there first.
    expect(find.text('Workspace'), findsOneWidget);

    // We navigate to the "Shared with Me" tab to see our fake board
    final sharedTab = find.text('Shared with Me');
    await tester.tap(sharedTab);
    await tester.pumpAndSettle();

    // Verify the fake board is visible
    expect(find.text('Fake Board'), findsOneWidget);
    expect(find.byIcon(Icons.grid_view_rounded), findsWidgets);
  });
}

class FakeAuthNotifier extends AuthNotifier {
  @override
  Future<AuthSession?> build() async {
    return null; // Start unauthenticated
  }

  @override
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    final session = AuthSession(
      userId: 'user_1',
      token: 'fake_token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
    
    state = AsyncData(session);
  }
}

class FakeBoardNotifier extends BoardNotifier {
  @override
  Future<List<Board>> build() async {
    return [
      Board(
        id: '1',
        title: 'Fake Board',
        description: 'Test Description',
        createdAt: DateTime.now(),
        ownerId: 'user_1',
        columns: [],
        members: [],
      ),
    ];
  }
}
