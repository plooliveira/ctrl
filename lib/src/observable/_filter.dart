part of 'observable.dart';

class _AutoDisposeFilter<D> extends Observable<Iterable<D>> {
  final Observable<Iterable<D>> base;
  final bool Function(D value) filter;

  @override
  Iterable<D> get value => base.value.where(filter);

  _AutoDisposeFilter(this.base, this.filter) : super([], base.scope) {
    base.addListener(_onBasedChanged);
  }

  void _onBasedChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    base.removeListener(_onBasedChanged);
    super.dispose();
  }
}
