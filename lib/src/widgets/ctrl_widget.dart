import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:ctrl/ctrl.dart';

/// A simplified widget for views that need exactly one controller.
///
/// [CtrlWidget] is a [StatefulWidget] that automatically manages the lifecycle
/// of a single [Ctrl] instance. It is a generic class that takes a [Ctrl] as
/// a type parameter.
///
/// By default, it uses the built-in service locator to resolve the [Ctrl].
/// You can register your [Ctrl] in the service locator before running the app:
///
/// ```dart
/// void setupLocator() {
///   Locator().registerFactory((_) => CounterController());
/// }
/// ```
///
/// You can override the [resolveCtrl] method to inject a custom [Ctrl] instance.
/// This is useful for testing or when using other dependency injection frameworks.
///
/// ### Cascade State Composition (CSC)
///
/// [CtrlWidget] enables Cascade State Composition where each widget maintains
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
abstract class CtrlWidget<T extends Ctrl> extends StatefulWidget {
  const CtrlWidget({super.key});

  /// Override this method to provide a custom [Ctrl] instance.
  /// By default, it retrieves the [Ctrl] from the service locator.
  /// Override this method to provide a custom [Ctrl] instance using a different method. e.g. GetIt, Provider, Constructor injection etc.
  T? resolveCtrl(BuildContext context) => null;

  /// Override this method to provide a [Widget] to be built.
  ///
  /// Example:
  /// ```dart
  /// class UserProfile extends CtrlWidget<UserProfileController> {
  ///   final String userId;
  ///   const UserProfile({super.key, required this.userId});
  ///
  ///   @override
  ///   void onInit(BuildContext context, UserProfileController ctrl) {
  ///     ctrl.setUserId(userId);
  ///   }
  ///
  ///   @override
  ///   Widget build(BuildContext context, UserProfileController ctrl) {
  ///     return Text('User: $userId');
  ///   }
  /// }
  /// ```
  Widget build(BuildContext context, T ctrl);

  /// Override this method to provide a custom [onInit] callback.
  void onInit(BuildContext context, T ctrl) {}

  /// Override this method to react to widget updates.
  ///
  /// Called whenever the widget configuration changes. Use this to pass
  /// updated props to the controller. The controller should contain the logic
  /// to determine if any action is needed.
  ///
  /// Example:
  /// ```dart
  /// class UserProfile extends CtrlWidget<UserProfileController> {
  ///   final String userId;
  ///   const UserProfile({super.key, required this.userId});
  ///
  ///   @override
  ///   void onUpdate(BuildContext context, UserProfileController ctrl) {
  ///     ctrl.setUserId(userId); // Controller decides if reload is needed
  ///   }
  /// ...
  /// }
  /// ```
  void onUpdate(BuildContext context, T ctrl) {}

  @protected
  @nonVirtual
  @override
  State createState() => _ViewWidgetAdapter<T, CtrlWidget<T>>();
}

class _ViewWidgetAdapter<T extends Ctrl, W extends CtrlWidget<T>>
    extends CtrlState<W> {
  late final T _ctrl;

  @override
  void initState() {
    _ctrl = useCtrl(widget.resolveCtrl(context));
    super.initState();
    widget.onInit(context, _ctrl);
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    widget.onUpdate(context, _ctrl);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return widget.build(context, _ctrl);
  }
}
