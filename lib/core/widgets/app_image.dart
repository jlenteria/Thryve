import 'package:flutter/material.dart';

import '../services/image_store.dart';

/// Renders any image reference Thryve stores: a `local:` file, a legacy
/// `data:` URI, or a remote URL. Shows a neutral placeholder on failure.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String? source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final Widget placeholder = Container(
      width: width,
      height: height,
      color: colors.surfaceContainer,
      child: Icon(Icons.image_outlined, color: colors.outline),
    );
    final ImageProvider<Object>? provider = ImageStore.provider(source);
    Widget image = provider == null
        ? placeholder
        : Image(
            image: provider,
            width: width,
            height: height,
            fit: fit,
            gaplessPlayback: true,
            errorBuilder: (_, _, _) => placeholder,
            loadingBuilder:
                (
                  BuildContext context,
                  Widget child,
                  ImageChunkEvent? progress,
                ) {
                  if (progress == null) {
                    return child;
                  }
                  return Container(
                    width: width,
                    height: height,
                    color: colors.surfaceContainer,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  );
                },
          );
    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.source, this.radius = 16});

  final String? source;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final ImageProvider<Object>? image = ImageStore.provider(source);
    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.primary.withValues(alpha: 0.1),
      backgroundImage: image,
      onBackgroundImageError: image == null ? null : (_, _) {},
      child: image == null
          ? Icon(
              Icons.person_outline,
              size: radius * 1.2,
              color: colors.primary,
            )
          : null,
    );
  }
}
