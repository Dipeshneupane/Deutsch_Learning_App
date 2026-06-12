import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.bottomNavigation,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? bottomNavigation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      bottomNavigationBar: bottomNavigation,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth > 900 ? 980 : 680,
                ),
                child: Padding(padding: const EdgeInsets.all(20), child: child),
              ),
            );
          },
        ),
      ),
    );
  }
}
