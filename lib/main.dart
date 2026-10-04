import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/services/notification_service.dart';
import 'core/theme/theme_manager.dart';
import 'screens/main_shell.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'view_models/app_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surfaceContainerLowest,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const ThryveApp());
}

class ThryveApp extends StatelessWidget {
  const ThryveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <ChangeNotifierProvider<dynamic>>[
        ChangeNotifierProvider<ThemeManager>(create: (_) => ThemeManager()),
        ChangeNotifierProvider<AppViewModel>(
          create: (_) => AppViewModel()..load(),
        ),
      ],
      child: Consumer<ThemeManager>(
        builder: (BuildContext context, ThemeManager theme, Widget? child) {
          return MaterialApp(
            title: 'Thryve',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: switch (theme.currentTheme) {
              ThemeType.dark => ThemeMode.dark,
              ThemeType.system => ThemeMode.system,
              _ => ThemeMode.light,
            },
            home: Consumer<AppViewModel>(
              builder: (BuildContext context, AppViewModel app, Widget? child) {
                if (!app.isLoaded) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return app.onboardingComplete
                    ? const MainShell()
                    : const OnboardingFlow();
              },
            ),
          );
        },
      ),
    );
  }
}
