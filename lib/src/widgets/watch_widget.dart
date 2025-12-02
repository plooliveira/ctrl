import 'dart:async';

import 'package:flutter/material.dart';
import '../observable/observable.dart';

/// Widget that rebuilds when a [Observable] value changes.
///
/// [Watch] observes a single [Observable] and rebuilds its child widget
/// whenever the value changes. The builder receives the current value.
///
/// Example:
/// ```dart
/// Watch(
///   viewModel.counter,
///   builder: (context, value) {
///     return Text('Counter: $value');
///   },
/// )
/// ```
///
/// See also:
/// * [GroupWatch], for observing multiple LiveData objects
/// * [Observable], the observable data holder
class Watch<T> extends StatefulWidget {
  const Watch(this.notifier, {required this.builder, super.key});

  /// The [Observable] to observe.
  final Observable<T> notifier;

  /// Builder function called with the current value.
  ///
  /// Called initially and whenever the [notifier] value changes.
  final Widget Function(BuildContext, T) builder;

  @override
  State createState() => _WatchState<T>();
}

class _WatchState<T> extends State<Watch<T>> with WatchMixin {
  @override
  List<Observable<T>> get _notifiers => [widget.notifier];

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, widget.notifier.value);
}

/// Widget that rebuilds when any of multiple [Observable] values change.
///
/// [GroupWatch] observes multiple [Observable] instances and rebuilds
/// whenever any of them change. Access values directly from your ViewModel
/// in the builder.
///
/// Example:
/// ```dart
/// GroupWatch(
///   [viewModel.name, viewModel.age],
///   builder: (context) {
///     return Text('${viewModel.name.value} is ${viewModel.age.value}');
///   },
/// )
/// ```
///
/// See also:
/// * [Watch], for observing a single LiveData
class GroupWatch extends StatefulWidget {
  /// List of [Observable] instances to observe.
  final List<Observable> notifiers;

  /// Builder function called when any notifier changes.
  final Widget Function(BuildContext) builder;

  GroupWatch(this.notifiers, {required this.builder, Key? key})
    : super(key: key ?? ValueKey(notifiers));

  @override
  State createState() => _GroupWatchState();
}

class _GroupWatchState extends State<GroupWatch> with WatchMixin {
  @override
  List<Observable> get _notifiers => widget.notifiers;

  @override
  Widget build(BuildContext context) => widget.builder(context);
}

/// Mixin that handles LiveData observation lifecycle.
///
/// Automatically subscribes to notifiers in [initState] and
/// unsubscribes in [dispose]. Calls [setState] when any notifier changes.
mixin WatchMixin<T extends StatefulWidget> on State<T> {
  List<Observable> get _notifiers;
  bool _isUpdateScheduled = false;

  /// If overriding, be sure to call super.initState.
  @override
  void initState() {
    super.initState();
    for (final notifier in _notifiers) {
      notifier.addListener(_onNotifierChanged);
    }
  }

  /// If overriding, be sure to call super.dispose.
  @override
  void dispose() {
    for (final notifier in _notifiers) {
      notifier.removeListener(_onNotifierChanged);
    }
    super.dispose();
  }

  void _onNotifierChanged() {
    if (_isUpdateScheduled) return;
    _isUpdateScheduled = true;
    scheduleMicrotask(() {
      _isUpdateScheduled = false;
      if (mounted) setState(() {});
    });
  }
}
