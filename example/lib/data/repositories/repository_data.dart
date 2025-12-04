import 'package:ctrl/ctrl.dart';

abstract class RepositoryData<T> {
  T get value;

  Observable<T> get live;

  Observable<S> transform<S>(S Function(Observable<T> data) transform);
  void dispose();
}

class RepositoryDataImpl<T> extends _SourceRepositoryData<T, Observable<T>> {
  @override
  final Observable<T> source;

  RepositoryDataImpl(this.source);
}

class MutableRepositoryData<T>
    extends _SourceRepositoryData<T, MutableObservable<T>> {
  @override
  final MutableObservable<T> source;

  MutableRepositoryData({
    T? value,
    MutableObservable<T>? source,
    bool Function(T, T)? changeDetector,
  }) : source = source ?? MutableObservable(value as T) {
    if (changeDetector != null) {
      this.source.changeDetector = changeDetector;
    }
  }

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
