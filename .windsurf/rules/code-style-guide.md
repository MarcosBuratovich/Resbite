---
trigger: always_on
---

---
description: Code style and best practices for the AI in Resbite (Flutter project using Windsurf with o3 model integration).
globs: **/*.dart
alwaysApply: false
---

# 🧠 Resbite AI – Flutter Code Style Guide (Windsurf o3)

## 📁 Folder Structure

- `lib/models/` – Data models (mapped to Supabase)
- `lib/screens/` – Full UI screens
- `lib/widgets/` – Reusable UI components
- `lib/services/` – Business logic and Supabase integration
- `lib/providers/` or `lib/bloc/` – App-wide state management
- `lib/utils/` – Helpers and utilities
- `lib/theme/` – App-wide style configuration

---

## ✅ General Principles

- **No mocks allowed.**  
  All logic must use **live Supabase integration** (REST, RPC, Realtime). Avoid any fake data, `MockClient`, or delayed futures simulating API calls.

- **Business logic must not live in widgets.**  
  Extract to services or state providers.

- **Keep the code AI-ready.**  
  `o3` model workflows rely on consistent structure and naming for automated understanding and generation. Avoid ambiguous patterns.

---

## 🧱 Flutter Widget Rules

- Use `StatelessWidget` for pure, presentational components.
- Use `StatefulWidget` only when local state is required:

```dart
class Counter extends StatefulWidget {
  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;

  void _increment() {
    setState(() { _count++; });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $_count'),
        ElevatedButton(onPressed: _increment, child: Text('Increment')),
      ],
    );
  }
}

    Prefer const constructors whenever possible.

    Break down large widgets (>200 LOC) into smaller, readable parts.

## 🧠 AI Model (o3) Integration

    Clearly name your classes, methods, and variables to align with expected app domain.

    Avoid overuse of dynamic or var – type annotations help the model reason about structure.

    Document services and models where needed to help o3 infer behavior.

## 🔄 State Management

    Preferred: Riverpod
    Alternatives: Bloc or Provider (only if justified).

    Avoid using setState() for shared or complex state.

    App state should reflect and stay in sync with Supabase whenever possible (subscriptions, queries, etc.).


## 🌐 Navigation

    Use Navigator.pushNamed() with central route definitions (lib/routes.dart).

    Avoid hardcoding route strings in multiple places.


## 🎨 Styling

    Use a global theme (colors, text styles, spacing) in theme/.

    No inline styles or hardcoded color values.

    Use Theme.of(context) for consistency and maintainability.


## ⏳ Async Logic and Supabase

    Always use async/await with proper error handling:

try {
  final data = await Supabase.instance.client.from('users').select();
} catch (error) {
  // Handle gracefully
}

    Use FutureBuilder only for simple, isolated cases.
    For screens or heavy logic, use state providers or reactive listeners.

## 🧪 Testing Policy

    No mocking tools like mockito.

    Integration tests should connect to real Supabase data (ideally via a test environment or separate tables).

    For predictable tests, use Supabase edge functions or RPCs with known inputs.