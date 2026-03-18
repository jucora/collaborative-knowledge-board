# Collaborative Knowledge Board

A modern, high-performance task management application built with Flutter, designed for seamless team collaboration. This project implements a sophisticated **Offline-First (Local-First)** architecture with real-time synchronization capabilities.

---
### 👨‍💻 Author
**Julian Andres Belmonte Ortiz**  
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/julianbel/)

---

## 🚀 Key Features

*   **Dynamic Board Interface:** Interactive columns and cards with a focus on UX and responsiveness.
*   **Advanced Drag & Drop:** Custom-built drag-and-drop system featuring "Ghost Card" previews for smooth visual feedback.
*   **Offline-First Sync Engine:** Robust synchronization service that queues actions when the connection is lost and replays them automatically when back online.
*   **Real-Time Simulation:** A built-in developer panel to simulate network events, external card creation, and connectivity toggling.
*   **Adaptive Theming:** Deep Navy and Neon aesthetic with full support for Light and Dark modes.
*   **Responsive Layout:** Optimized for both mobile and desktop screen ratios.

## 🏗️ Architecture & Tech Stack

The project follows **Clean Architecture** principles, ensuring scalability, maintainability, and testability.

*   **Framework:** [Flutter](https://flutter.dev)
*   **State Management:** [Riverpod 2.0](https://riverpod.dev) (using `AsyncNotifier`, `FamilyAsyncNotifier`, and code generation).
*   **Backend:** [Supabase](https://supabase.com/) for authentication and real-time database.
*   **Navigation:** [GoRouter](https://pub.dev/packages/go_router) for declarative routing.
*   **Functional Programming:** [Dartz](https://pub.dev/packages/dartz) for `Either` types and functional error handling.
*   **Dependency Injection:** Handled natively via Riverpod Providers.
*   **Styling:** Custom Material 3 themes with a vibrant, modern color palette.

## 📡 Local-First Strategy & Synchronization

The core of this application is a **Local-First** data approach combined with a dual-datasource strategy. This ensures a zero-latency user experience and full offline functionality.

### 1. Hybrid Datasource Architecture
The application leverages a flexible abstraction layer for data access:
- **Supabase Production Source:** Handles persistent remote storage, real-time subscriptions (PostgreSQL CDC), and authentication.
- **In-Memory/Fake Datasource:** Used for rapid prototyping, automated testing, and as a fallback mechanism. This allows developers to test complex synchronization edge cases (like race conditions or conflict resolution) in a controlled environment.

### 2. Synchronization Engine (`SyncService`)
Instead of blocking the UI waiting for server responses, the system operates as follows:
1.  **Optimistic UI Update:** When a user performs an action (e.g., moving a card), the Riverpod state is updated immediately.
2.  **Connectivity-Aware Persistence:**
    - **Online:** The action is forwarded to the `RemoteDatasource` (Supabase).
    - **Offline:** The action is serialized and pushed into a `PersistentActionQueue`.
3.  **Automatic Reconciliation:** The `SyncService` monitors connectivity changes. Upon reconnection, it executes a "replay" of the pending queue, ensuring the local state and remote database are eventually consistent.

### 3. Real-Time Integration
Using Supabase's real-time capabilities, the app listens for changes made by other collaborators. The `Local-First` logic is smart enough to distinguish between local optimistic updates and incoming remote changes to prevent unnecessary UI flickers.

## 🧪 Testing Excellence

The project maintains a high standard of quality through a comprehensive testing suite that ensures reliability in both online and offline scenarios.

*   **Isolated Widget Testing:** UI components are tested in total isolation using Riverpod `overrides`. By injecting "Fake" Notifiers, we verify UI behavior without requiring a live Supabase instance or network connectivity.
*   **End-to-End Integration Flow:** A complete "Login to Dashboard" flow is implemented to verify authentication logic, routing redirecciones (GoRouter), and data rendering.
*   **Deterministic Network Mocks:** Advanced testing techniques are used to mock low-level Flutter `MethodChannels` (like `shared_preferences`), ensuring that the Supabase initialization logic behaves correctly in a headless test environment.
*   **Clean Architecture Validation:** Tests are decoupled from data implementations, ensuring that business logic remains valid regardless of whether the app is using the real backend or in-memory mocks.

## 🛠️ Development Tools

### Real-Time Simulator
To facilitate testing without a live backend or to stress-test the sync logic, the app includes a **Real-Time Simulator Panel**. This tool allows:
- Toggling network status (Online/Offline).
- Injecting "external" data changes to verify real-time UI updates.
- Monitoring the status of the synchronization queue.

**To run the app with the simulator enabled:**

```bash
flutter run --dart-define=SHOW_SIMULATOR=true
```

## 📦 Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-username/collaborative_knowledge_board.git
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the application:**
    ```bash
    flutter run
    ```

---
*Collaborative Knowledge Board - 2026*
