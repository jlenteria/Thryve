import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_nav.dart';
import '../view_models/main_shell_view_model.dart';
import '../view_models/app_view_model.dart';
import '../view_models/weekly_review_view_model.dart';
import 'home/home_dashboard.dart';
import 'goals/goals_hub_screen.dart';
import 'wall/my_wall_screen.dart';
import 'review/weekly_review_screen.dart';
import 'settings/settings_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MainShellViewModel()),
        ChangeNotifierProvider(
          create: (BuildContext context) =>
              WeeklyReviewViewModel(context.read<AppViewModel>()),
        ),
      ],
      child: Consumer<MainShellViewModel>(
        builder: (context, shellVm, _) {
          final AppViewModel app = context.watch<AppViewModel>();
          final pages = <Widget>[
            const HomeDashboard(),
            const GoalsHubScreen(),
            const MyWallScreen(),
            const WeeklyReviewScreen(),
            const SettingsScreen(),
          ];

          return Scaffold(
            body: IndexedStack(index: shellVm.currentIndex, children: pages),
            bottomNavigationBar: ThryveBottomNav(
              currentIndex: shellVm.currentIndex,
              onTap: shellVm.setIndex,
            ),
          );
        },
      ),
    );
  }
}
