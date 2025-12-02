import 'dart:async';
import 'package:flutter/material.dart';

import '../ctrl.dart';

/// Base class for Controllers in the MVVM pattern.
///
/// [Controller] manages the business logic for the UI layer.
/// It provides lifecycle management, automatic
/// disposal of [Observable] and other [ChangeNotifier] objects through [DataScope], and built-in loading state management.
///
/// Key features:
/// * Methods [mutable] and [register] for creating observable data
/// * Automatic disposal of all registered [Observable] instances
/// * Built-in [isLoading] for tracking long-running operations
/// * Reacts to the UI lifecycle with [onActive] and [onInactive] callbacks, which are invoked when the associated view becomes visible or is hidden.
///
/// Example:
/// ```dart
/// class CounterController extends Controller {
///   final _counter = mutable(0);
///   Observable<int> get counter => _counter;
///
///   void increment() {
///     _counter.value++;
///   }
///
///   @override
///   void onActive() {
///     // Called when the view becomes active
///   }
/// }
/// ```
///
/// See also:
/// * [ViewState], for connecting Controllers to widgets
/// * [Observable] and [MutableObservable], for observable data
/// * [DataScope], for managing Observable lifecycle
abstract class Controller extends _LifecycleController {
  Controller() {
    _isLoading = mutable(false);
  }

  /// Observable flag indicating if a long-running action is in progress.
  ///
  /// You can Use [beginLoading] and [completeLoading] to control this flag manually,
  /// or use [executeAsync] to automatically manage it around asynchronous operations with error catching.

  Observable<bool> get isLoading => _isLoading;
  late final MutableObservable<bool> _isLoading;

  /// Marks the start of a long-running action.
  ///
  /// Sets [isLoading] to `true`. Always pair with [completeLoading]
  /// to avoid leaving the action state active indefinitely.
  void beginLoading() => _isLoading.value = true;

  /// Marks the end of a long-running action.
  ///
  /// Sets [isLoading] to `false`.
  void completeLoading() => _isLoading.value = false;

  /// Executes an asynchronous action while managing the loading state.
  ///
  /// Sets [isLoading] to `true` before starting the action,
  /// and sets it back to `false` when the action completes, whether
  /// it completes successfully or with an error.
  ///
  /// Example:
  /// ```dart
  /// Future<void> fetchData() async {
  ///   await executeAsync(() async {
  ///     await repository.getData();
  ///   });
  /// }
  /// ```
  Future<T> executeAsync<T>(Future<T> Function() action) async {
    beginLoading();
    try {
      return await action();
    } catch (e) {
      rethrow;
    } finally {
      completeLoading();
    }
  }
}

abstract class _LifecycleController {
  /// Scope for managing the lifecycle of [Observable] instances.
  ///
  /// All Observable created with [mutable] or [register] are automatically
  /// added to this scope and disposed when the Controller is disposed.
  final DataScope scope = DataScope();

  bool _isActive = false;

  /// Whether this Controller is currently active.
  ///
  /// Set to `true` when the associated view becomes active (visible),
  /// and `false` when it becomes inactive. This is managed automatically
  /// by [ViewState].
  bool get isActive => _isActive;

  set isActive(bool active) {
    if (active != _isActive) {
      if (active) {
        _isActiveCompleter.complete();
        onActive();
      } else {
        _isActiveCompleter = Completer();
        onInactive();
      }
    }
    _isActive = active;
  }

  Completer _isActiveCompleter = Completer();

  /// Creates a [MutableObservable] and registers it in the Controller's scope.
  ///
  /// The created Observable will be automatically disposed when the Controller
  /// is disposed. This is the recommended way to create observable state
  /// in your Controller.
  ///
  /// Example:
  /// ```dart
  /// class MyController extends Controller {
  ///   final _name = mutable('John');
  ///   Observable<String> get name => _name;
  /// }
  /// ```
  MutableObservable<T> mutable<T>(T value) => scope.mutable(value);

  /// Registers an existing [Observable] in the Controller's scope.
  ///
  /// The registered Observable will be automatically disposed when the
  /// Controller is disposed. Use this when you create Observable instances
  /// that aren't created with [mutable].
  ///
  /// Example:
  /// ```dart
  /// final custom = register(CustomObservable());
  /// ```
  T register<T extends Observable>(T value) => scope.add(value);

  /// Called when the associated view becomes active (visible).
  ///
  /// Override this method to perform actions when the view is shown,
  /// such as starting streams, subscribing to updates, etc.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void onActive() {
  ///   _subscription = repository.stream.listen(_onData);
  /// }
  /// ```
  void onActive() {}

  /// Called when the associated view becomes inactive (hidden).
  ///
  /// Override this method to perform cleanup when the view is hidden,
  /// such as pausing streams, canceling subscriptions, etc.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void onInactive() {
  ///   _subscription?.cancel();
  /// }
  /// ```
  void onInactive() {}

  void dispose() {
    scope.dispose();
  }

  /// Waits until the Controller becomes active.
  ///
  /// This is useful for operations that should only execute when the
  /// view is visible. The Future completes immediately if already active.
  ///
  /// Example:
  /// ```dart
  /// Future<void> loadData() async {
  ///   await ensureActive();
  ///   // Now we know the view is active
  ///   fetchDataFromServer();
  /// }
  /// ```
  Future ensureActive() async {
    while (!_isActive) {
      await _isActiveCompleter.future;
    }
  }
}
