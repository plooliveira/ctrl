part of 'scope.dart';

/// Extension methods for creating [MutableObservable] within a [DataScope].
extension MutableDataScope on DataScope {
  /// Creates and registers a [MutableObservable] with an initial value.
  ///
  /// This is a convenience method that creates a MutableObservable and
  /// automatically adds it to this scope for lifecycle management.
  ///
  /// Example:
  /// ```dart
  /// final scope = DataScope();
  /// final counter = scope.mutable(0);
  /// final name = scope.mutable('John');
  /// ```
  MutableObservable<T> mutable<T>(T start) {
    return add(MutableObservable(start));
  }

  /// Creates a MutableObservable that mirrors a source Observable.
  ///
  /// Creates a MutableObservable that starts with the source's value and
  /// automatically updates whenever the source changes. Changes to the
  /// returned MutableObservable do NOT affect the source (unidirectional).
  /// The bridge is automatically cleaned up when this scope is disposed.
  ///
  /// Example:
  /// ```dart
  /// final source = MutableObservable(42);
  /// final mirror = scope.bridgeFrom(source);
  /// source.value = 10; // mirror.value becomes 10
  /// mirror.value = 20; // source.value remains 10
  /// ```
  MutableObservable<T> bridgeFrom<T>(Observable<T> source) {
    final mirror = add(MutableObservable<T>(source.value));

    void listener() {
      mirror.value = source.value;
    }

    source.addListener(listener);

    final cleanup = _DisposeCallback(() {
      source.removeListener(listener);
      if (remove(mirror)) {
        mirror.dispose();
      }
    });

    add(cleanup);
    return mirror;
  }
}

/// Extension methods for combining multiple [Observable] or [ChangeNotifier] sources.
extension DataScopeExtensions on DataScope {
  /// Combines multiple Observable sources using a mediator function.
  ///
  /// Creates a Observable that updates whenever any of the [sources] change.
  /// The [mediate] function is called to compute the new value.
  ///
  /// Example:
  /// ```dart
  /// final firstName = MutableLiveData('John');
  /// final lastName = MutableLiveData('Doe');
  ///
  /// final fullName = scope.join([firstName, lastName], () {
  ///   return '${firstName.value} ${lastName.value}';
  /// });
  /// ```
  Observable<T> join<T>(List<Observable> sources, T Function() mediate) =>
      add(_MediatorLiveData(sources, mediate));

  /// Merges multiple ChangeNotifier sources into a single LiveData.
  ///
  /// Similar to [join] but works with any [ChangeNotifier], not just LiveData.
  /// The [transform] function is called whenever any source notifies.
  ///
  /// Example:
  /// ```dart
  /// final notifier1 = ValueNotifier(1);
  /// final notifier2 = ValueNotifier(2);
  ///
  /// final sum = scope.merge([notifier1, notifier2], () {
  ///   return notifier1.value + notifier2.value;
  /// });
  /// ```
  Observable<T> merge<T>(List<ChangeNotifier> sources, T Function() transform) {
    return _MergedLiveData<T>(
      sources: sources,
      transform: transform,
      scope: this,
    );
  }
}
