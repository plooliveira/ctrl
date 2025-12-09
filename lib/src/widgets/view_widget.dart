import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:ctrl/ctrl.dart';

/// A [CtrlWidget] is a simplified version of a [StatefulWidget] + [ViewState].
/// It is a generic class that takes a [Ctrl] as a type parameter.
/// By default, it uses the built-in service locator to resolve the [Ctrl].
/// You can register your [Ctrl] in the service locator before running the app:
///
/// ```dart
/// void setupLocator() {
///   Locator().registerFactory(() => CounterController());
/// }
/// ```
///
/// You can override the [resolveCtrl] method to inject a [Ctrl].
/// This is useful for testing.
///
/// ### Cascade State Composition (CSC)
///
/// ViewWidget enables Cascade State Composition where each widget maintains
/// its own isolated Controller while cascading state changes to children
/// through reactive constructor injection.
///
/// #### How it works:
/// - Parent manages its own state via Controller
/// - Parent injects data into children via constructor
/// - Children receive injected data and manage their own state
/// - State changes cascade down but never up
/// ```dart
/// // Each level can:
/// // 1. Modify its own state
/// // 2. Inject data into child (influencing child's UI)
///
/// Parent
///   ├─ Own State: ParentController
///   └─ Injects into child: parentData
///        ↓
///      Child
///        ├─ Own State: ChildController
///        ├─ Receives from parent: parentData
///        └─ Injects into child: childData
///             ↓
///           GrandChild
///             ├─ Own State: GrandChildController
///             └─ Receives from parent: childData
/// ```
mixin CtrlWidget<T extends Ctrl> on StatefulWidget {
  /// Override this method to provide a custom [Ctrl] instance.
  /// By default, it retrieves the [Ctrl] from the service locator.
  /// Override this method to provide a custom [Ctrl] instance using a different method. e.g. GetIt, Provider, Constructor injection etc.
  T? resolveCtrl(BuildContext context) => null;

  /// Override this method to provide a [Widget] to be built.
  /// ```dart
  /// class UserProfile extends ViewWidget<UserProfileController> {
  ///   final String userId;
  /// @override
  ///   void onInit(BuildContext context, UserProfileController controller) {
  ///     controller.setUserId(userId);
  ///   }
  /// ...
  /// }
  /// ```
  Widget build(BuildContext context, T controller);

  /// Override this method to provide a custom [onInit] callback.
  void onInit(BuildContext context, T controller) {}

  /// Override this method to react to widget updates.
  ///
  /// Called whenever the widget configuration changes. Use this to pass
  /// updated props to the ViewModel. The ViewModel should contain the logic
  /// to determine if any action is needed.
  ///
  /// Example:
  /// ```dart
  /// class UserProfile extends ViewWidget<UserProfileController> {
  ///   final String userId;
  ///
  ///   @override
  ///   void onUpdate(BuildContext context, UserProfileController controller) {
  ///     controller.setUserId(userId); // ViewModel decides if reload is needed
  ///   }
  /// ...
  /// }
  /// ```
  void onUpdate(BuildContext context, T controller) {}

  @protected
  @nonVirtual
  @override
  State createState() => _ViewWidgetAdapter<T, CtrlWidget<T>>();
}

class _ViewWidgetAdapter<V extends Ctrl, W extends CtrlWidget<V>>
    extends CtrlState<V, W> {
  @override
  V resolveCtrl() {
    return widget.resolveCtrl(context) ?? super.resolveCtrl();
  }

  @override
  void initState() {
    super.initState();
    widget.onInit(context, ctrl);
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    widget.onUpdate(context, ctrl);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return widget.build(context, ctrl);
  }
}
