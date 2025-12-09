import 'package:flutter/material.dart';
import 'package:ctrl/ctrl.dart';
import 'package:mocktail/mocktail.dart';

class MockCounterViewModel extends Mock implements CounterViewModel {}

class CounterViewModel with Ctrl {
  late final counter = mutable(0);

  void increment() => counter.value++;
}

class TrackableCounterViewModel extends CounterViewModel {
  int disposeCallCount = 0;

  @override
  void dispose() {
    disposeCallCount++;
    super.dispose();
  }
}

class TrackingViewModel with Ctrl {
  late final counter = mutable(0);
}

class TrackingView extends StatefulWidget {
  const TrackingView({super.key});

  @override
  State<TrackingView> createState() => TrackingViewState();
}

class TrackingViewState extends CtrlState<TrackingViewModel, TrackingView> {
  int buildCount = 0;

  @override
  Widget build(BuildContext context) {
    buildCount++;
    return MaterialApp(home: Scaffold(body: Text('Build count: $buildCount')));
  }
}

// View de teste para usar com ViewState
class CounterView extends StatefulWidget {
  const CounterView({super.key});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends CtrlState<CounterViewModel, CounterView> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Watch(
              ctrl.counter,
              builder: (context, value) => Text('Counter: $value'),
            ),
            Text('ViewModel Active: ${ctrl.isActive}'),
          ],
        ),
      ),
    );
  }
}

class MockObservable<T> extends Mock implements Observable<T> {}

class ProfileViewModel with Ctrl {
  late final name = mutable('John');
  late final age = mutable(30);
}

class UserViewModel with Ctrl {
  late final userId = mutable<String?>(null);
  late final userData = mutable<String>('No data');

  String? _lastUserId;
  int reloadCount = 0;

  void setUserId(String? id) {
    if (_lastUserId != id) {
      _lastUserId = id;
      userId.value = id;
      reloadCount++;
      userData.value = 'User data for $id';
    }
  }
}

class CallbackTracker {
  int onInitCallCount = 0;
  int onUpdateCallCount = 0;
  BuildContext? lastContext;
  Ctrl? lastViewModel;

  void reset() {
    onInitCallCount = 0;
    onUpdateCallCount = 0;
    lastContext = null;
    lastViewModel = null;
  }
}

class TestViewWidget extends StatefulWidget with CtrlWidget<CounterViewModel> {
  final CallbackTracker? tracker;

  const TestViewWidget({super.key, this.tracker});

  @override
  void onInit(BuildContext context, CounterViewModel viewModel) {
    tracker?.onInitCallCount++;
    tracker?.lastContext = context;
    tracker?.lastViewModel = viewModel;
  }

  @override
  void onUpdate(BuildContext context, CounterViewModel viewModel) {
    tracker?.onUpdateCallCount++;
    tracker?.lastContext = context;
    tracker?.lastViewModel = viewModel;
  }

  @override
  Widget build(BuildContext context, CounterViewModel viewModel) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Watch(
              viewModel.counter,
              builder: (context, value) => Text('Counter: $value'),
            ),
            Text('ViewModel Active: ${viewModel.isActive}'),
          ],
        ),
      ),
    );
  }
}

class SimpleTestViewWidget extends StatefulWidget
    with CtrlWidget<CounterViewModel> {
  const SimpleTestViewWidget({super.key});

  @override
  Widget build(BuildContext context, CounterViewModel viewModel) {
    return Watch(
      viewModel.counter,
      builder: (context, value) => Text('Counter: $value'),
    );
  }
}

class UserProfileWidget extends StatefulWidget with CtrlWidget<UserViewModel> {
  final String userId;
  final CallbackTracker? tracker;

  const UserProfileWidget({super.key, required this.userId, this.tracker});

  @override
  void onInit(BuildContext context, UserViewModel viewModel) {
    tracker?.onInitCallCount++;
    viewModel.setUserId(userId);
  }

  @override
  void onUpdate(BuildContext context, UserViewModel viewModel) {
    tracker?.onUpdateCallCount++;
    viewModel.setUserId(userId);
  }

  @override
  Widget build(BuildContext context, UserViewModel viewModel) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Text('UserId: $userId'),
            Watch(
              viewModel.userData,
              builder: (context, data) => Text('Data: $data'),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomResolveViewWidget extends StatefulWidget
    with CtrlWidget<CounterViewModel> {
  final CounterViewModel? customViewModel;

  const CustomResolveViewWidget({super.key, this.customViewModel});

  @override
  CounterViewModel? resolveCtrl(BuildContext context) => customViewModel;

  @override
  Widget build(BuildContext context, CounterViewModel viewModel) {
    return MaterialApp(
      home: Scaffold(
        body: Watch(
          viewModel.counter,
          builder: (context, value) => Text('Counter: $value'),
        ),
      ),
    );
  }
}

class ParentViewWidget extends StatefulWidget
    with CtrlWidget<CounterViewModel> {
  final int sharedValue;

  const ParentViewWidget({super.key, required this.sharedValue});

  @override
  Widget build(BuildContext context, CounterViewModel viewModel) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Text('Parent Counter: ${viewModel.counter.value}'),
            ChildViewWidget(parentValue: sharedValue),
          ],
        ),
      ),
    );
  }
}

class ChildViewWidget extends StatefulWidget with CtrlWidget<CounterViewModel> {
  final int parentValue;

  const ChildViewWidget({super.key, required this.parentValue});

  @override
  Widget build(BuildContext context, CounterViewModel viewModel) {
    return Column(
      children: [
        Text('Parent Value: $parentValue'),
        Watch(
          viewModel.counter,
          builder: (context, counter) => Text('Child Counter: $counter'),
        ),
      ],
    );
  }
}
