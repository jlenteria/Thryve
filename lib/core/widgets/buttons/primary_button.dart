import 'package:flutter/material.dart';

/// Filled call-to-action. Drops its icon rather than overflowing when the
/// available width is tight.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: expanded ? double.infinity : null,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.primary.withValues(alpha: 0.45),
          disabledForegroundColor: colors.onPrimary.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        child: isLoading
            ? SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: colors.onPrimary,
                ),
              )
            : ButtonContent(label: label, icon: icon, iconAfterLabel: true),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expanded ? double.infinity : null,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: ButtonContent(label: label, icon: icon),
      ),
    );
  }
}

/// Label + optional icon that hides the icon when the label alone barely
/// fits, instead of overflowing.
class ButtonContent extends StatelessWidget {
  const ButtonContent({
    super.key,
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
        final TextPainter painter = TextPainter(
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
                painter.width + 28 <= constraints.maxWidth);
        painter.dispose();
        final Widget text = Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        );
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (showIcon && !iconAfterLabel) ...<Widget>[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            text,
            if (showIcon && iconAfterLabel) ...<Widget>[
              const SizedBox(width: 8),
              Icon(icon, size: 20),
            ],
          ],
        );
      },
    );
  }
}
