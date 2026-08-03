
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/onboarding/screens/onboard_screen_view_model.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import 'app_router.dart';

part 'onboarding_route.g.dart';
@TypedGoRoute<OnboardingRoute>(path: '/onboarding')
class OnboardingRoute extends BaseRoute with $OnboardingRoute {
  const OnboardingRoute();

  @override
  Widget buildScreen(BuildContext context, GoRouterState state) => ChangeNotifierProvider<OnboardScreenViewModel>(
    create: (_) => OnboardScreenViewModel(),
    child: const OnboardingScreen(),
  );
}
