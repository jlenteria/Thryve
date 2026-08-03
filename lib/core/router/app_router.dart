import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import 'onboarding_route.dart' as onboarding;

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  routes: <RouteBase>[
    /// consolidated
    ...onboarding.$appRoutes,
  ],
  initialLocation: '/onboarding',
  redirect: _handleRedirect,
);

abstract class BaseRoute extends GoRouteData {
  const BaseRoute();

  Widget buildScreen(BuildContext context, GoRouterState state);

  @override
  Page<dynamic> buildPage(BuildContext context, GoRouterState state) =>
      CupertinoPage<dynamic>(
        child: buildScreen(context, state),
      );
}


String? _handleRedirect(BuildContext context, GoRouterState state) {
  // Prevent from navigating away from `/` if app is starting up
  return null;
}
