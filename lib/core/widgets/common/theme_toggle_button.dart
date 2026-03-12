import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

/// A reusable button to toggle between light and dark theme modes.
class ThemeToggleButton extends ConsumerWidget {
  final Color? color;

  const ThemeToggleButton({super.key, this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return IconButton(
      icon: Icon(
        themeMode == ThemeMode.light ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
        color: color,
      ),
      onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
      tooltip: "Toggle Dark/Light Mode",
    );
  }
}
