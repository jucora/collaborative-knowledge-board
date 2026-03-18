import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

/// A reusable and highly visible button to toggle between light and dark theme modes.
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    // Colores basados en la imagen del usuario
    const neonPink = Color(0xFFFF007F);
    const electricCyan = Color(0xFF00E5FF);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? electricCyan.withOpacity(0.1) : neonPink.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? electricCyan : neonPink,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? electricCyan : neonPink).withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => RotationTransition(
            turns: anim,
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            key: ValueKey(isDark),
            color: isDark ? electricCyan : neonPink,
            size: 24,
          ),
        ),
        onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
        tooltip: "Switch to ${isDark ? 'Light' : 'Dark'} Mode",
      ),
    );
  }
}
