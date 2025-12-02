import '../../ctrl.dart';

/// A [Observable] that can dynamically switch between different source Observable.
///
/// [HotswapObservable] observes a source Observable and can switch to observe
/// a different source at runtime using [hotswap]. This is useful for scenarios
/// where the data source needs to change dynamically, such as switching between
/// different repositories or API endpoints.
///
/// Example:
/// ```dart
/// final repo1Data = MutableObservable('Source 1');
/// final repo2Data = MutableObservable('Source 2');
///
/// final hotswap = HotswapObservable(repo1Data, scope);
/// print(hotswap.value); // 'Source 1'
///
/// hotswap.hotswap(repo2Data);
/// print(hotswap.value); // 'Source 2'
/// ```
///
/// See also:
/// * [LiveDataExtensions.hotswappable], extension method to create HotswapObservable
class HotswapObservable<T> extends Observable<T> {
  late Observable<T> _base;

  @override
  T get value => _base.value;

  /// Creates a HotswapObservable that initially observes [base].
  ///
  /// The [scope] parameter is optional and determines lifecycle management.
  HotswapObservable(Observable<T> base, DataScope? scope)
    : super(base.value, scope) {
    _base = base;
    changeDetector = base.changeDetector;
    _base.subscribe(_onBaseChanged);
  }

  /// Switches to observe a different Observable source.
  ///
  /// Unsubscribes from the current source and subscribes to the new [base].
  /// If [disposeOld] is `true` (default), the old source is disposed.
  /// Does nothing if the new base is the same as the current one.
  ///
  /// Example:
  /// ```dart
  /// final data1 = MutableObservable(1);
  /// final data2 = MutableObservable(2);
  /// final hotswap = HotswapObservable(data1, null);
  ///
  /// hotswap.hotswap(data2); // Switches to data2, disposes data1
  /// hotswap.hotswap(data2); // Does nothing (already observing data2)
  /// ```
  void hotswap(Observable<T> base, {bool disposeOld = true}) {
    if (_base == base) {
      return;
    }
    _base.unsubscribe(_onBaseChanged);
    if (disposeOld) {
      _base.dispose();
    }
    _base = base;
    changeDetector = base.changeDetector;
    _base.subscribe(_onBaseChanged);
    notifyIfChanged();
  }

  void _onBaseChanged(T value) {
    notifyIfChanged();
  }

  @override
  void dispose() {
    _base.unsubscribe(_onBaseChanged);
    super.dispose();
  }
}
