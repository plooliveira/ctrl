import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ctrl/ctrl.dart';
import 'counter_controller.dart';

class CounterRoute extends GoRoute {
  CounterRoute()
    : super(
        path: '/counter',
        name: 'counter',
        builder: (context, state) => CounterView(),
      );
}

class CounterView extends StatefulWidget with CtrlWidget<CounterController> {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context, CounterController controller) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Watch rebuilds only when counter value changes
            Watch(
              controller.counter,
              builder: (context, value) => Text(
                '$value',
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Separate Watch for loading indicator
            Watch(
              controller.isLoading,
              builder: (context, isLoading) {
                return SizedBox(
                  height: 40,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const SizedBox.shrink(),
                );
              },
            ),

            const SizedBox(height: 40),

            // Watch disables buttons during async operations
            Watch(
              controller.isLoading,
              builder: (context, isLoading) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : controller.decrement,
                      icon: const Icon(Icons.remove),
                      label: const Text('-1'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : controller.increment,
                      icon: const Icon(Icons.add),
                      label: const Text('+1'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : controller.increment100Async,
                      icon: const Icon(Icons.schedule),
                      label: const Text('+100 Async'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
