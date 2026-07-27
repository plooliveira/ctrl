# Ctrl Playground

This is a **demonstration playground** for the [ctrl](https://github.com/plooliveira/ctrl) package, illustrating the practical implementation of **Ctrl** capabilities in different real-world Flutter development scenarios.

## 🎯 Purpose

The playground demonstrates how to use the Ctrl package in various contexts, including:

- Reactive state management with Observable
- Complex object manipulation with Observable.update()
- Observable transformations and combinations
- HotswapObservable for dynamic data source switching
- Data layer integration using Repository Pattern
- Reactive Local database integration

## 📋 Included Examples

### 1. Counter
Basic demonstration of `Observable`, `Watch`, and loading states.

### 2. Counter (Cascade)
Demonstrates cascade state composition, where parent and child widgets keep isolated controllers while passing data downward.

### 3. Theme Switcher
Demonstrates `HotswapObservable` for dynamically switching between different observable sources at runtime.

### 4. Product Form
Demonstrates mutable model updates with `Observable.update()` for granular form state changes.

### 5. Todo List
Complete example using the repository pattern, reactive local persistence, and CRUD flows.


## 🏗️ Project Structure

This project follows a **simple and pragmatic structure**, focused on demonstrating the use of `Ctrl` in a clear and didactic way:

```
lib/
├── core/           # Settings, routes and shared components
├── data/           # Models, repositories and data layer
├── view/           # Views and Ctrl classes (controllers / view models)
└── main.dart       # Application entry point
```

## 🚀 How to Run

1. Clone the ctrl repository
2. Navigate to the example folder:
   ```bash
   cd example
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the project:
   ```bash
   flutter run
   ```

## 📚 Learning

Each example in the playground is independent and self-contained, allowing you to:

- Explore the source code of each feature
- Understand how to integrate Ctrl in different scenarios
- See code organization best practices
- Learn scalable architecture patterns

---

**Note:** This is an educational demonstration project. For production applications, consider adding additional layers of abstraction, comprehensive tests, and other patterns as your project's complexity requires.
