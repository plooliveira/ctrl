import '../../ctrl.dart';

/// Base interface for repository data holders.
///
/// [RepositoryData] provides a common interface for accessing data from
/// repositories, whether mutable or immutable. It offers both direct value
/// access and observable Observable.
///
/// See also:
/// * [LiveRepositoryData], for immutable repository data
/// * [MutableRepositoryData], for mutable repository data
abstract class RepositoryData<T> {
  /// The current value.
  T get value;

  /// Returns a Observable that observes this repository data.
  Observable<T> get live;

  /// Transforms the data into a different type.
  ///
  /// Returns a Observable that applies [transform] to compute its value.
  Observable<S> transform<S>(S Function(Observable<T> data) transform);
  void dispose();
}

/// Repository data backed by an immutable Observable source.
///
/// Wraps an existing Observable to provide repository-style access patterns.
/// Use this when you have read-only data from a repository.
///
/// Example:
/// ```dart
/// final liveData = MutableObservable(42);
/// final repo = LiveRepositoryData(liveData);
/// print(repo.value); // 42
/// final observed = repo.live; // Get an immutable Observable
/// ```
class LiveRepositoryData<T> extends _SourceRepositoryData<T, Observable<T>> {
  @override
  final Observable<T> source;

  /// Creates a LiveRepositoryData wrapping the given [source].
  LiveRepositoryData(this.source);
}

/// Repository data backed by a MutableObservable source.
///
/// Provides both read and write access to repository data.
/// Use this when you need to modify repository data.
///
/// Example:
/// ```dart
/// final repo = MutableRepositoryData(value: 0);
/// print(repo.value); // 0
/// repo.value = 42;
/// print(repo.value); // 42
/// ```
class MutableRepositoryData<T>
    extends _SourceRepositoryData<T, MutableObservable<T>> {
  @override
  final MutableObservable<T> source;

  /// Creates a MutableRepositoryData.
  ///
  /// Provide either [value] to create a new MutableObservable, or [source]
  /// to wrap an existing one. Optionally set a custom [changeDetector].
  ///
  /// Example:
  /// ```dart
  /// // Create with initial value
  /// final repo1 = MutableRepositoryData(value: 0);
  ///
  /// // Wrap existing MutableObservable
  /// final liveData = MutableObservable(0);
  /// final repo2 = MutableRepositoryData(source: liveData);
  /// ```
  MutableRepositoryData({
    T? value,
    MutableObservable<T>? source,
    bool Function(T, T)? changeDetector,
  }) : source = source ?? MutableObservable(value as T) {
    if (changeDetector != null) {
      this.source.changeDetector = changeDetector;
    }
  }

  /// Sets a new value for the repository data.
  ///
  /// Delegates to the underlying MutableObservable source.
  set value(T to) {
    source.value = to;
  }
}

abstract class _SourceRepositoryData<T, D extends Observable<T>>
    extends RepositoryData<T> {
  @override
  T get value => source.value;

  D get source;

  @override
  Observable<T> get live => source.mirror();

  @override
  Observable<S> transform<S>(S Function(Observable<T>) transform) =>
      source.transform(transform);

  @override
  void dispose() {
    source.dispose();
  }
}
