part of 'package:ctrl/src/observable/observable.dart';

/// Extension methods for [Observable] transformation and manipulation.
extension LiveDataExtensions<T> on Observable<T> {
  /// Creates a mirror that observes this Observable.
  ///
  /// Returns a new Observable that automatically updates when this
  /// Observable's value changes. Useful for exposing read-only views.
  ///
  /// Example:
  /// ```dart
  /// final original = MutableObservable(42);
  /// final mirrored = original.mirror();
  /// original.value = 10; // mirrored.value becomes 10
  /// ```
  Observable<T> mirror() => _LiveDataMirror(this);

  /// Transforms this Observable into a different type.
  ///
  /// Creates a new Observable that computes its value by applying the
  /// [transform] function whenever this Observable changes.
  ///
  /// The returned Observable shares the same scope as the source and will
  /// be automatically disposed when the source is disposed.
  ///
  /// Example:
  /// ```dart
  /// final counter = MutableObservable(5);
  /// final doubled = counter.transform((data) => data.value * 2);
  /// // doubled.value is 10
  /// ```
  Observable<S> transform<S>(S Function(Observable<T> data) transform) =>
      _TransformedLiveDataMirror(this, transform: transform);

  /// Converts this Observable into a HotswapObservable.
  ///
  /// Returns a [HotswapObservable] that initially observes this Observable
  /// but can later switch to observe a different source.
  ///
  /// Example:
  /// ```dart
  /// final data1 = MutableObservable(1);
  /// final hotswap = data1.hotswappable();
  ///
  /// final data2 = MutableObservable(2);
  /// hotswap.hotswap(data2); // Now observes data2
  /// ```
  HotswapObservable<T> hotswappable([DataScope? scope]) =>
      HotswapObservable(this, scope);
}

/// Extension methods for [Observable] containing collections.
extension ListObservable<D> on Observable<Iterable<D>> {
  /// Whether the current collection is empty.
  bool get isEmpty => value.isEmpty;

  /// Whether the current collection is not empty.
  bool get isNotEmpty => value.isNotEmpty;

  /// The number of elements in the current collection.
  int get length => value.length;

  /// Maps each element to a new value.
  ///
  /// Convenience shorthand for `value.map(toElement)`.
  Iterable<T> map<T>(T Function(D value) toElement) => value.map(toElement);

  /// Applies a function to each element.
  ///
  /// Convenience shorthand for `value.forEach(action)`.
  void forEach(void Function(D element) action) => value.forEach(action);

  /// Expands each element into zero or more elements.
  ///
  /// Convenience shorthand for `value.expand(toElements)`.
  Iterable<T> expand<T>(Iterable<T> Function(D element) toElements) =>
      value.expand(toElements);

  /// Creates a Observable that filters elements based on a condition.
  ///
  /// Returns a new Observable that updates whenever this Observable changes,
  /// containing only elements that satisfy the [check] function.
  ///
  /// The returned Observable shares the same scope as the source and will
  /// be automatically disposed when the source is disposed.
  ///
  /// Example:
  /// ```dart
  /// final numbers = MutableObservable([1, 2, 3, 4, 5]);
  /// final evens = numbers.filtered((n) => n % 2 == 0);
  /// // evens.value is [2, 4]
  /// ```
  Observable<Iterable<D>> filtered(bool Function(D value) check) =>
      _AutoDisposeFilter(this, check);

  /// Creates a Observable that filters out null elements.
  ///
  /// Returns a new Observable containing only non-null elements.
  ///
  /// The returned Observable shares the same scope as the source and will
  /// be automatically disposed when the source is disposed.
  ///
  /// Example:
  /// ```dart
  /// final items = MutableObservable([1, null, 2, null, 3]);
  /// final nonNull = items.notNull();
  /// // nonNull.value is [1, 2, 3]
  /// ```
  Observable<Iterable<D>> notNull() =>
      _AutoDisposeFilter<D>(this, (value) => value != null);
}
