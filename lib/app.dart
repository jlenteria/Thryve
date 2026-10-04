import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/state/app_view_model.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_manager.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/shell/screens/main_shell.dart';

class ThryveApp extends StatelessWidget {
  const ThryveApp({super.key, this.appViewModel});

  /// Injectable for tests; production builds create and load their own.
  final AppViewModel? appViewModel;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <ChangeNotifierProvider<ChangeNotifier>>[
        ChangeNotifierProvider<ThemeManager>(create: (_) => ThemeManager()),
        ChangeNotifierProvider<AppViewModel>(
          create: (_) => appViewModel ?? (AppViewModel()..load()),
        ),
      ],
      child: Consumer<ThemeManager>(
        builder: (BuildContext context, ThemeManager theme, _) => MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: theme.themeMode,
          builder: (BuildContext context, Widget? child) =>
              _SystemChrome(child: child!),
          home: const _AppGate(),
        ),
      ),
    );
  }
}

/// Shows onboarding or the main shell, and refreshes day-based state when
/// the app returns to the foreground (e.g. the next morning).
class _AppGate extends StatefulWidget {
  const _AppGate();

  @override
  State<_AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<_AppGate> with WidgetsBindingObserver {
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final AppViewModel app = context.read<AppViewModel>();
      if (app.isLoaded) {
        app.refreshDay();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppViewModel app = context.watch<AppViewModel>();
    if (!app.isLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: app.onboardingComplete
          ? const MainShell(key: ValueKey<String>('shell'))
          : const OnboardingScreen(key: ValueKey<String>('onboarding')),
    );
  }
}

/// Keeps status/navigation bar icons legible in both themes.
class _SystemChrome extends StatelessWidget {
  const _SystemChrome({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool dark = colors.brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: colors.surfaceContainerLowest,
          ),
      child: child,
    );
  }
}
