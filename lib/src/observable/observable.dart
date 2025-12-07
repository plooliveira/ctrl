import 'dart:async';

import 'package:flutter/material.dart';

import '../../ctrl.dart';

part '_mirror.dart';
part '_filter.dart';
part '_extensions.dart';

/// A function that determines if a value has changed.
///
/// Returns `true` if [a] and [b] are different values.
typedef ChangeDetector<T> = bool Function(T a, T b);

bool _defaultChangeDetector<T>(T to, T from) {
  return to != from;
}

/// An observable data holder.
///
/// [Observable] is the core class of the mvvm_kit package. It holds a value
/// and notifies observers when that value changes. Use it with [Watch] or
/// [GroupWatch] widgets to automatically rebuild UI when data changes.
///
/// This is an abstract class. Use [MutableObservable] for data you can modify,
/// or create instances using factory methods like [MutableObservable.fromValueNotifier]
/// and [Observable.fromStream].
///
/// Example:
/// ```dart
/// class CounterController extends Controller {
///   final _counter = MutableObservable(0);
///   Observable<int> get counter => _counter;
///
///   void increment() => _counter.value++;
/// }
///
/// // In your widget:
/// Watch(
///   controller.counter,
///   builder: (context, value) => Text('$value'),
/// )
/// ```
///
/// See also:
/// * [MutableObservable], for creating mutable observable data
/// * [Watch], for observing a single Observable in widgets
/// * [GroupWatch], for observing multiple Observable objects
abstract class Observable<T> with ChangeNotifier {
  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  bool _isExecuting = false;
  bool get isExecuting => _isExecuting;

  final List<Function(T)> _subscribers = [];

  final DataScope? scope;
  final DataScope? parentScope;

  @visibleForTesting
  List<Function(T)> get subscribers => _subscribers;

  /// The current value held by this Observable.
  ///
  /// Accessing this getter returns the current value without triggering
  /// any notifications. To observe changes, use [Watch] widget or [subscribe].
  T get value;

  T? _lastNotifyCheck;

  Observable([T? value, this.parentScope])
    : scope = parentScope?.child() ?? DataScope() {
    _lastNotifyCheck = value;
    parentScope?.add(this);
  }

  /// Converts a [ValueNotifier] into a [Observable].
  ///
  /// Creates a new Observable that observes the given [notifier] and
  /// automatically synchronizes when the notifier's value changes.
  /// The original [ValueNotifier] remains independent and functional.
  ///
  /// Example:
  /// ```dart
  /// final notifier = ValueNotifier<int>(0);
  /// final observable = Observable.fromValueNotifier(notifier);
  /// notifier.value = 1; // observable updates automatically
  /// ```
  factory Observable.fromValueNotifier(
    ValueNotifier<T> notifier, [
    DataScope? scope,
  ]) {
    return _ValueNotifierData(notifier, scope);
  }

  /// Creates a nullable Observable from a [Stream].
  ///
  /// Returns a `Observable<T?>` that updates automatically when the stream
  /// emits new values. The [initialValue] is used until the first stream
  /// emission.
  ///
  /// Note: Returns `Observable<T?>` because stream values can be null.
  ///
  /// Example:
  /// ```dart
  /// final stream = Stream.periodic(Duration(seconds: 1), (i) => i);
  /// final observable = Observable.fromStream(stream, 0);
  /// ```
  static Observable<T?> fromStream<T>(
    Stream<T> stream,
    T initialValue, [
    DataScope? scope,
  ]) {
    return _StreamData<T, T, Stream<T>>(stream, scope, value: initialValue);
  }

  /// Shorthand for accessing [value].
  ///
  /// Allows calling the Observable instance as a function to get its value.
  ///
  /// Example:
  /// ```dart
  /// final data = MutableObservable(42);
  /// print(data()); // prints: 42
  /// ```
  T call() => value;

  /// Function that determines if the value has changed.
  ///
  /// Override this to customize change detection behavior. By default,
  /// uses standard equality (`!=`).
  ///
  /// Note: For mutable objects like [List] or [Map], modifying the content
  /// without changing the reference will NOT trigger a change. Use
  /// [MutableObservable.update] or create a new instance to notify observers.
  late ChangeDetector<T> changeDetector = _defaultChangeDetector;

  /// Subscribes to value changes with a callback function.
  ///
  /// The [callback] is immediately invoked with the current value, then
  /// called again whenever the value changes. Returns this Observable instance
  /// for method chaining.
  ///
  /// Use [unsubscribe] to remove the callback later.
  ///
  /// Example:
  /// ```dart
  /// observable.subscribe((value) {
  ///   print('Value changed to: $value');
  /// });
  /// ```
  Observable<T> subscribe(Function(T value) callback) {
    if (!_subscribers.contains(callback)) {
      _subscribers.add(callback);
      callback(value);
    }
    return this;
  }

  /// Forces notification of all observers even if the value hasn't changed.
  ///
  /// Useful when you need to trigger a UI rebuild or callback execution
  /// without actually changing the underlying value.
  void reload() {
    notifyListeners();
  }

  /// Removes a previously registered callback.
  ///
  /// Use this to stop receiving notifications from a [subscribe] callback.
  ///
  /// Example:
  /// ```dart
  /// void onValueChanged(int value) => print(value);
  ///
  /// observable.subscribe(onValueChanged);
  /// // later...
  /// observable.unsubscribe(onValueChanged);
  /// ```
  void unsubscribe(Function(T value) callback) {
    _subscribers.remove(callback);
  }

  /// Notifies all observers only if the value has changed.
  ///
  /// Compares the current value with the last notified value using
  /// [changeDetector]. Only triggers notifications if they differ.
  /// This is used internally but can be useful when extending Observable.
  ///
  /// Use [reload] if you want to force notification regardless of changes.
  void notifyIfChanged() {
    final T currentValue = value;
    if (_lastNotifyCheck == null ||
        changeDetector(currentValue, _lastNotifyCheck as T)) {
      _lastNotifyCheck = currentValue;
      notifyListeners();
    }
  }

  /// Notifies all observers and executes all subscribed callbacks.
  ///
  /// This override ensures that both Flutter's [ChangeNotifier] listeners
  /// and [subscribe] callbacks are invoked with the current value.
  ///
  /// Typically you don't need to call this directly - use [reload] or
  /// modify values through [MutableObservable.value] instead.
  @override
  void notifyListeners() {
    super.notifyListeners();
    final value = this.value;
    for (var callback in _subscribers.toList()) {
      callback(value);
    }
  }

  /// Disposes this Observable and cleans up all resources.
  ///
  /// Clears all subscribers, disposes the internal [scope], and removes
  /// this Observable from its [parentScope]. After calling dispose, this
  /// Observable should not be used anymore.
  ///
  /// The [Ctrl] automatically disposes all Observable instances
  /// registered in its scope, so manual disposal is usually not needed.
  @override
  void dispose() {
    _isDisposed = true;
    _isExecuting = false;
    _subscribers.clear();
    scope?.dispose();
    parentScope?.remove(this);
    super.dispose();
  }
}

/// A mutable version of [Observable] that allows changing its value.
///
/// stored value. When the value is set, all observers are automatically
/// notified (if the value actually changed according to [changeDetector]).
///
/// **Important**: By default, change detection uses standard equality (`!=`).
/// If you modify a mutable object (like a List) in place and assign it back,
/// it will NOT trigger a notification because the reference is the same.
/// Use [update] for in-place modifications.
///
/// This is the most commonly used Observable type in Controllers for
/// managing state that changes over time.
///
/// Example:
/// ```dart
/// class CounterController extends Controller {
///   final _counter = MutableObservable(0);
///   Observable<int> get counter => _counter;
///
///   void increment() {
///     _counter.value++; // Automatically notifies observers
///   }
/// }
/// ```
///
/// See also:
/// * [Observable], the immutable base class
/// * [Ctrl.mutable], for creating MutableObservable in a Controller scope
class MutableObservable<T> extends Observable<T> {
  T _value;

  @override
  T get value => _value;

  /// Creates a [MutableObservable] with an initial value.
  ///
  /// The [emitAll] parameter, when set to `true`, forces notifications
  /// for every assignment, even if the value hasn't changed. By default,
  /// notifications only occur when the value actually changes.
  ///
  /// Example:
  /// ```dart
  /// final counter = MutableObservable(0);
  /// final alwaysNotify = MutableObservable(0, true);
  /// ```
  MutableObservable(T super.value, [bool emitAll = false, super.scope])
    : _value = value {
    if (emitAll) {
      changeDetector = (T to, T from) => true;
    }
  }

  /// Sets a new value and notifies observers if it has changed.
  ///
  /// Uses [changeDetector] to determine if the value has actually changed.
  /// Only notifies observers when the new value differs from the current one
  /// (unless [emitAll] was set to `true` in the constructor).
  ///
  /// **Note**: Assigning the same object reference (even if modified) will
  /// NOT trigger a notification by default. Use [update] for that.
  ///
  /// Example:
  /// ```dart
  /// final name = MutableObservable('John');
  /// name.value = 'Jane'; // Notifies observers
  /// name.value = 'Jane'; // Does NOT notify (same value)
  /// ```
  set value(T to) {
    if (changeDetector(to, _value)) {
      _value = to;
      notifyListeners();
    }
  }

  /// Returns this MutableObservable as a [Observable] reference.
  ///
  /// This doesn't create a true immutable copy, but returns the same
  /// instance typed as [Observable]. Useful for exposing the Observable
  /// through a public getter while keeping the mutable field private.
  ///
  /// Note: Callers can still cast back to MutableObservable if needed.
  ///
  /// Example:
  /// ```dart
  /// class MyController extends Controller {
  ///   final _data = MutableObservable(0);
  ///   Observable<int> get data => _data.immutable;
  ///   // or simply: Observable<int> get data => _data;
  /// }
  /// ```
  Observable<T> get immutable => this;

  /// Updates the value by applying a transformation function.
  ///
  /// This is useful when you need to modify a complex object in place
  /// without replacing it entirely. The [block] function receives the
  /// current value and can modify it. After the block executes, all
  /// observers are notified.
  ///
  /// Example:
  /// ```dart
  /// final list = MutableLiveData<List<int>>([1, 2, 3]);
  /// list.update((value) => value.add(4)); // Adds 4 and notifies
  /// ```
  void update(Function(T value) block) {
    block(_value);
    notifyListeners();
  }

  void asyncUpdate(Future<void> Function(T value) block) async {
    _isExecuting = true;
    notifyListeners();
    try {
      await block(_value);
    } finally {
      _isExecuting = false;
      notifyListeners();
    }
  }
}
