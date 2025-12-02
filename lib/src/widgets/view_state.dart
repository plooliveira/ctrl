import 'package:ctrl/ctrl.dart';
import 'package:ctrl/src/helpers/debugger.dart';
import 'package:flutter/material.dart';

/// Base state for MVC views.
///
/// [ViewState] manages the lifecycle connection between a [StatefulWidget] and
/// its [Controller]. It automatically:
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
/// * [Controller], which provides onActive/onInactive callbacks
abstract class ViewState<T extends Controller, W extends StatefulWidget>
    extends _BaseState<W> {
  /// Creates the Controller instance to be used by this ViewState.
  /// By default, it retrieves the Controller from the service locator.
  /// Override this method to provide a custom Controller instance using a different method. e.g. GetIt, Provider, Constructor injection etc.
  @protected
  T resolveController() => Locator().get();

  /// The Controller instance associated with this ViewState.
  late final T controller = resolveController();
  bool _isUpdateScheduled = false;

  @override
  void initState() {
    super.initState();
    controller.isActive = true;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _disposeController() {
    controller.dispose();
    debugLog(
      'Disposed Controller: ${controller.runtimeType}, from View: ${widget.runtimeType}',
    );
  }

  /// Synchronizes Controller.isActive with app lifecycle state. If you need to override, be sure to call super.didChangeAppLifecycleState.
  ///
  /// Sets to `true` when resumed, `false` when inactive/hidden/paused.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        controller.isActive = true;
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        controller.isActive = false;
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
