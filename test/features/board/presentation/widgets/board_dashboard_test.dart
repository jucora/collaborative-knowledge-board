import 'package:collaborative_knowledge_board/features/auth/domain/entities/auth_session.dart';
import 'package:collaborative_knowledge_board/features/auth/presentation/providers/auth_notifier.dart';
import 'package:collaborative_knowledge_board/features/auth/presentation/providers/auth_providers.dart';
import 'package:collaborative_knowledge_board/features/board/domain/entities/board.dart';
import 'package:collaborative_knowledge_board/features/board/presentation/pages/board_dashboard_page.dart';
import 'package:collaborative_knowledge_board/features/board/presentation/providers/board_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  // We initialize Supabase once for all tests in this file
  // to avoid the "Supabase instance not initialized" error.
  setUpAll(() async {
    // We use TestWidgetsFlutterBinding to ensure the widget environment is ready
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock for shared_preferences to avoid MissingPluginException in tests
    // Supabase uses shared_preferences internally for local storage.
    const MethodChannel channel = MethodChannel('plugins.flutter.io/shared_preferences');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{}; // Returns an empty map to simulate no saved session
      }
      return null;
    });

    // Minimal Supabase initialization with dummy values
    await Supabase.initialize(
      url: 'https://fake.url.supabase.co',
      anonKey: 'fake_anon_key',
    );
  });

  testWidgets('Dashboard should show list of boards', (WidgetTester tester) async {
    // arrange
    final tBoards = [
      Board(
        id: '1',
        title: 'Board 1',
        description: 'Test Description 1',
        createdAt: DateTime.now(),
        ownerId: 'user_1',
        columns: [],
        members: [],
      ),
      Board(
        id: '2',
        title: 'Board 2',
        description: 'Test Description 2',
        createdAt: DateTime.now(),
        ownerId: 'user_1',
        columns: [],
        members: [],
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // We override the auth notifier so Riverpod manages it
          authNotifierProvider.overrideWith(() => FakeAuthNotifier()),
          // We override the board notifier to return our test data
          boardNotifierProvider.overrideWith(() => FakeBoardNotifier(tBoards)),
        ],
        child: const MaterialApp(
          home: BoardDashboardPage(),
        ),
      ),
    );

    // We wait for the initial UI to be built (My Boards tab)
    await tester.pumpAndSettle();

    // EXPLANATION: Since we cannot inject a user into the static Supabase instance
    // without initializing the full real Auth system, Supabase.instance...currentUser will be null.
    // This causes the widget logic to filter boards into the "Shared with Me" tab.

    // We navigate to the "Shared with Me" tab
    final sharedTab = find.text('Shared with Me');
    await tester.tap(sharedTab);
    await tester.pumpAndSettle(); // We wait for the tab change animation

    // assert
    expect(find.text('Board 1'), findsOneWidget);
    expect(find.text('Board 2'), findsOneWidget);
    expect(find.byType(ListView), findsWidgets);
  });
}

// Fake class for the Auth Notifier
class FakeAuthNotifier extends AuthNotifier {
  @override
  Future<AuthSession?> build() async {
    return AuthSession(
      userId: 'user_1',
      token: 'fake_token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }
}

// Fake class for the Board Notifier
class FakeBoardNotifier extends BoardNotifier {
  final List<Board> boards;
  FakeBoardNotifier(this.boards);

  @override
  Future<List<Board>> build() async {
    return boards;
  }
}