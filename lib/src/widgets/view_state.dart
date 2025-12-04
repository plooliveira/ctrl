import 'package:ctrl/ctrl.dart';
import 'package:ctrl/src/helpers/debugger.dart';
import 'package:flutter/material.dart';

/// Base state for MVC views.
///
/// [ViewState] manages the lifecycle connection between a [StatefulWidget] and
/// its [Ctrl]. It automatically:
/// * Sets the Controller as active/inactive based on widget lifecycle
/// * Responds to app lifecycle changes (background/foreground)
/// * Disposes the Controller when the widget is disposed
///
/// This allows you to have full control of the view lifecycle, useful when you need
/// to override lifecycle methods (didUpdateWidget, didChangeDependencies, etc.) or
/// manage complex view logic like animations, controllers, or mixins.
/// For more simple use cases, consider using [ViewWidget].
///
/// Example:
/// ```dart
/// class _CounterViewState extends ViewState<CounterController, CounterView> {
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: Watch(
///         controller.counter,
///         builder: (context, value) => Text('$value'),
///       ),
///     );
///   }
/// }
/// ```
///
/// See also:
/// * [Ctrl], which provides onActive/onInactive callbacks
abstract class ViewState<T extends Ctrl, W extends StatefulWidget>
    extends _BaseState<W> {
  /// Creates the Controller instance to be used by this ViewState.
  /// By default, it retrieves the Controller from the service locator.
  /// Override this method to provide a custom Controller instance using a different method. e.g. GetIt, Provider, Constructor injection etc.
  @protected
  T resolveCtrl() => Locator().get();

  /// The Controller instance associated with this ViewState.
  late final T ctrl = resolveCtrl();

  @override
  void initState() {
    super.initState();
    ctrl.isActive = true;
  }

  @override
  void dispose() {
    _disposeCtrl();
    super.dispose();
  }

  void _disposeCtrl() {
    ctrl.dispose();
    debugLog(
      'Disposed Controller: ${ctrl.runtimeType}, from View: ${widget.runtimeType}',
    );
  }

  /// Synchronizes Controller.isActive with app lifecycle state. If you need to override, be sure to call super.didChangeAppLifecycleState.
  ///
  /// Sets to `true` when resumed, `false` when inactive/hidden/paused.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        ctrl.isActive = true;
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        ctrl.isActive = false;
        break;
      default:
      // Nothing to do here
    }
  }
}

abstract class _BaseState<W extends StatefulWidget> extends State<W>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
