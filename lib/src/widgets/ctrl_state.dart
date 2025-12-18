import 'package:ctrl/ctrl.dart';
import 'package:ctrl/src/helpers/debugger.dart';
import 'package:flutter/material.dart';

/// Base state for views that need to manage multiple controllers or require
/// full control over the widget lifecycle.
///
/// [CtrlState] manages the lifecycle connection between a [StatefulWidget] and
/// one or more [Ctrl] instances. It automatically:
/// * Sets controllers as active/inactive based on widget lifecycle
/// * Responds to app lifecycle changes (background/foreground)
/// * Disposes all controllers when the widget is disposed
///
/// Use [useCtrl] to register controllers that should be managed by this state.
/// This allows you to have full control of the view lifecycle, useful when you need
/// to override lifecycle methods (didUpdateWidget, didChangeDependencies, etc.) or
/// manage complex view logic like animations, text controllers, or mixins.
///
/// For simple use cases with a single controller, consider using [CtrlWidget].
///
/// Example:
/// ```dart
/// class _CounterViewState extends CtrlState<CounterView> {
///   late final CounterController ctrl;
///
///   @override
///   void initState() {
///     ctrl = useCtrl<CounterController>();
///     super.initState();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: Watch(
///         ctrl.counter,
///         builder: (context, value) => Text('$value'),
///       ),
///     );
///   }
/// }
/// ```
///
/// See also:
/// * [Ctrl], which provides onActive/onInactive callbacks
/// * [CtrlWidget], for simple single-controller widgets
abstract class CtrlState<W extends StatefulWidget> extends _BaseState<W> {
  final List<Ctrl> _ctrls = [];

  /// Registers a controller to be managed by this state.
  ///
  /// If [ctrl] is provided, it will be registered and returned.
  /// If [ctrl] is null, a controller of type [S] will be resolved from the
  /// service locator and registered.
  ///
  /// All registered controllers will have their lifecycle managed automatically:
  /// * Activated when the widget is initialized or app resumes
  /// * Deactivated when the app goes to background
  /// * Disposed when the widget is disposed
  ///
  /// Example:
  /// ```dart
  /// late final MainController mainCtrl;
  /// late final AuthController authCtrl;
  /// late final MyController customCtrl;
  ///
  /// @override
  /// void initState() {
  ///   mainCtrl = useCtrl();
  ///   authCtrl = useCtrl();
  ///   customCtrl = useCtrl(MyController(customParam));
  ///   super.initState();
  /// }
  /// ```
  @protected
  S useCtrl<S extends Ctrl>([S? ctrl]) {
    if (ctrl == null) {
      final locatedCtrl = Locator().get<S>();
      _ctrls.add(locatedCtrl);
      return locatedCtrl;
    }
    _ctrls.add(ctrl);
    return ctrl;
  }

  @override
  void initState() {
    super.initState();
    _activateCtrls();
  }

  void _activateCtrls() {
    for (var ctrl in _ctrls) {
      ctrl.isActive = true;
    }
  }

  void _deactivateCtrls() {
    for (var ctrl in _ctrls) {
      ctrl.isActive = false;
    }
  }

  @override
  void dispose() {
    _disposeCtrl();
    super.dispose();
  }

  void _disposeCtrl() {
    for (var ctrl in _ctrls) {
      ctrl.dispose();
      debugLog(
        'Disposed Controller: ${ctrl.runtimeType}, from View: ${widget.runtimeType}',
      );
    }
  }

  /// Synchronizes Controller.isActive with app lifecycle state. If you need to override, be sure to call super.didChangeAppLifecycleState.
  ///
  /// Sets to `true` when resumed, `false` when inactive/hidden/paused.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        _activateCtrls();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _deactivateCtrls();
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
