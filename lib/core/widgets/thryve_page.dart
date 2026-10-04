import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../state/app_view_model.dart';
import 'app_image.dart';

/// Scaffold for the bottom-nav tabs: pinned brand header + padded content.
class ThryveTabPage extends StatelessWidget {
  const ThryveTabPage({super.key, required this.children, this.onAvatarTap});

  final List<Widget> children;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String? avatar = context.select<AppViewModel, String?>(
      (AppViewModel app) => app.user.avatar,
    );
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            toolbarHeight: 64,
            leadingWidth: 64,
            automaticallyImplyLeading: false,
            leading: Center(
              child: Semantics(
                button: onAvatarTap != null,
                label: 'Profile',
                child: GestureDetector(
                  onTap: onAvatarTap,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Avatar(source: avatar),
                  ),
                ),
              ),
            ),
            title: Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: const <Widget>[SizedBox(width: 64)],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverList.list(children: children),
          ),
        ],
      ),
    );
  }
}

/// Scaffold for pushed detail pages with a back button.
class ThryveDetailPage extends StatelessWidget {
  const ThryveDetailPage({
    super.key,
    required this.title,
    required this.children,
    this.actions,
  });

  final String title;
  final List<Widget> children;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: children,
        ),
      ),
    );
  }
}
