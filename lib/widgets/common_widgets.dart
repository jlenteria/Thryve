import 'dart:convert';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

ImageProvider<Object>? avatarImageProvider(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('data:image/')) {
    return MemoryImage(base64Decode(url.substring(url.indexOf(',') + 1)));
  }
  return NetworkImage(url);
}

void showNotifications(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Notifications',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(child: Icon(Icons.eco_outlined)),
            title: Text('Daily focus reminder'),
            subtitle: Text('Your next small action is ready when you are.'),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(child: Icon(Icons.auto_awesome_outlined)),
            title: Text('Weekly review'),
            subtitle: Text(
              'Reflect on your wins and choose next week\'s focus.',
            ),
          ),
        ],
      ),
    ),
  );
}

class ThryveBottomSheet extends StatelessWidget {
  const ThryveBottomSheet({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });

  final String title;
  final Widget content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            content,
            const SizedBox(height: 20),
            Wrap(alignment: WrapAlignment.end, spacing: 8, children: actions),
          ],
        ),
      ),
    );
  }
}

class ThryveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final VoidCallback? onTap;

  const ThryveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

class ProgressBar extends StatelessWidget {
  final double progress; // 0..1
  final double height;
  final Color? fillColor;
  final Color? trackColor;

  const ProgressBar({
    super.key,
    required this.progress,
    this.height = 10,
    this.fillColor,
    this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor:
            trackColor ?? AppColors.primary.withValues(alpha: 0.15),
        valueColor: AlwaysStoppedAnimation(fillColor ?? AppColors.primary),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expanded ? double.infinity : null,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        child: _ResponsiveButtonContent(
          label: label,
          icon: icon,
          iconAfterLabel: true,
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expanded ? double.infinity : null,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: _ResponsiveButtonContent(label: label, icon: icon),
      ),
    );
  }
}

class _ResponsiveButtonContent extends StatelessWidget {
  const _ResponsiveButtonContent({
    required this.label,
    this.icon,
    this.iconAfterLabel = false,
  });

  final String label;
  final IconData? icon;
  final bool iconAfterLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final TextPainter labelPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: DefaultTextStyle.of(context).style,
          ),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          maxLines: 1,
        )..layout();
        final bool showIcon =
            icon != null &&
            (!constraints.hasBoundedWidth ||
                labelPainter.width + 28 <= constraints.maxWidth);
        final Widget text = Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        );
        final List<Widget> children = <Widget>[
          if (showIcon && !iconAfterLabel) ...<Widget>[
            Icon(icon, size: 20),
            const SizedBox(width: 8),
          ],
          text,
          if (showIcon && iconAfterLabel) ...<Widget>[
            const SizedBox(width: 8),
            Icon(icon, size: 20),
          ],
        ];
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        );
      },
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  final Color? color;

  const SectionLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: color ?? AppColors.onSurfaceVariant,
        letterSpacing: 1.2,
      ),
    );
  }
}

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showLogo;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;

  const AppHeader({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.showLogo = false,
    this.avatarUrl,
    this.onAvatarTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,
      leadingWidth: 64,
      centerTitle: showLogo,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0.9),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ColorFilter.mode(
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            BlendMode.srcOver,
          ),
          child: Container(color: Colors.transparent),
        ),
      ),
      leading:
          leading ??
          (showLogo
              ? GestureDetector(
                  onTap: onAvatarTap,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Center(
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        backgroundImage: avatarImageProvider(avatarUrl),
                        child: avatarUrl == null
                            ? const Icon(
                                Icons.person_outline,
                                size: 19,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                    ),
                  ),
                )
              : null),
      title: showLogo
          ? Text(
              'Thryve',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            )
          : (title != null
                ? Text(
                    title!,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null),
      actions:
          actions ??
          [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => showNotifications(context),
            ),
            if (!showLogo && avatarUrl != null)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(avatarUrl!),
                ),
              ),
          ],
    );
  }
}

class ThryveSliverHeader extends StatelessWidget {
  const ThryveSliverHeader({
    super.key,
    required this.avatarUrl,
    this.onAvatarTap,
  });

  final String? avatarUrl;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      toolbarHeight: 64,
      leadingWidth: 64,
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0.96),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: GestureDetector(
        onTap: onAvatarTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              backgroundImage: avatarImageProvider(avatarUrl),
              child: avatarUrl == null
                  ? const Icon(
                      Icons.person_outline,
                      size: 19,
                      color: AppColors.primary,
                    )
                  : null,
            ),
          ),
        ),
      ),
      title: Text(
        'Thryve',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: <Widget>[
        SizedBox(
          width: 64,
          child: Center(
            child: IconButton(
              tooltip: 'Notifications',
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => showNotifications(context),
            ),
          ),
        ),
      ],
    );
  }
}

class NetworkImageSafe extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const NetworkImageSafe({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final Widget fallback = Container(
      width: width,
      height: height,
      color: AppColors.surfaceContainer,
      child: const Icon(Icons.image_outlined, color: AppColors.outline),
    );
    Widget image;
    if (url.startsWith('data:image/')) {
      try {
        image = Image.memory(
          base64Decode(url.substring(url.indexOf(',') + 1)),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => fallback,
        );
      } on FormatException {
        image = fallback;
      }
    } else {
      image = Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => fallback,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppColors.surfaceContainer,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    }
    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
