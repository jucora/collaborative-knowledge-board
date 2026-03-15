# Collaborative Knowledge Board

A modern, high-performance task management application built with Flutter, designed for seamless team collaboration. This project implements a sophisticated **Offline-First** architecture with real-time synchronization capabilities.

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

## 📡 Synchronization Logic

The application implements a custom `SyncService` that acts as a middleware between the UI and the Data Layer:
1.  **Local-First Update:** The UI updates immediately using Riverpod Notifiers.
2.  **Connectivity Check:** If online, the data is persisted via the Repository.
3.  **Action Queue:** If offline, the action is stored in a `pendingActions` queue.
4.  **Reconciliation:** When connectivity is restored, the service automatically synchronizes all pending changes to the server/datasource.

## 🛠️ Development Tools

### Real-Time Simulator
To facilitate testing without a live backend, the app includes a **Real-Time Simulator Panel**. For security and performance, this panel is excluded from production builds.

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
*Collaborative Knowledge Board - 2024*
