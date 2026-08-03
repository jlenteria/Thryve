import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nested/nested.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
     WidgetsBinding.instance.addPostFrameCallback((_) {
      // CustomToast.init();
    });

    return MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<ThemeManager>(
          create: (_) => ThemeManager.instance,
        )
      ],
      child: Consumer<ThemeManager>(
        builder: (_, ThemeManager provider, __) {
          return KeyedSubtree(
            key: provider.key,
            // ignore: always_specify_types
            child: AnnotatedRegion(
              value: SystemUiOverlayStyle.light.copyWith(
                statusBarIconBrightness: provider.isDarkMode ? Brightness.dark : Brightness.light,
                statusBarBrightness:  provider.isDarkMode ? Brightness.light : Brightness.dark,
                statusBarColor: Colors.transparent,
              ),
              child: Sizer(
                builder: (_, __, ___) {
                  return MaterialApp.router(
                    builder: FToastBuilder(),
                    theme: ThryvTheme.light,
                    darkTheme: ThryvTheme.dark,
                    themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                    debugShowCheckedModeBanner: false,
                    routerDelegate: appRouter.routerDelegate,
                    routeInformationProvider: appRouter.routeInformationProvider,
                    routeInformationParser: appRouter.routeInformationParser,
                    locale: const Locale('en'),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
