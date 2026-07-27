import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part './widgets/_exemplo_card.dart';

class HomeRoute extends GoRoute {
  HomeRoute()
    : super(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeView(),
      );
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ctrl Playground',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ExampleCard(
              title: 'Counter (Cascade)',
              description:
                  'CtrlWidget + Observable with cascade state composition',
              icon: Icons.add_circle_outline,
              onTap: () => context.push('/counter-cascade'),
            ),

            const SizedBox(height: 16),
            _ExampleCard(
              title: 'Counter',
              description:
                  'Basic Observable state with loading feedback',
              icon: Icons.add_circle_outline,
              onTap: () => context.push('/counter'),
            ),

            const SizedBox(height: 16),

            _ExampleCard(
              title: 'Product Form',
              description: 'Mutable model updates with Observable.update()',
              icon: Icons.edit_document,
              onTap: () => context.push('/product-form'),
              enabled: true,
            ),

            const SizedBox(height: 16),

            _ExampleCard(
              title: 'Theme Switcher',
              description: 'Dynamic source switching with HotswapObservable',
              icon: Icons.palette_outlined,
              onTap: () => context.push('/theme'),
              enabled: true,
            ),

            const SizedBox(height: 16),

            _ExampleCard(
              title: 'Todo List',
              description: 'Repository pattern with reactive local persistence',
              icon: Icons.checklist_outlined,
              onTap: () => context.push('/todo'),
              enabled: true,
            ),
          ],
        ),
      ),
    );
  }
}
