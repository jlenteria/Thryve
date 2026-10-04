import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/app_view_model.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/sheets.dart';
import '../../../core/widgets/thryve_card.dart';
import '../../../core/widgets/thryve_page.dart';
import '../../../data/models/wall_item.dart';
import '../../shell/view_models/main_shell_view_model.dart';
import '../widgets/wall_card.dart';
import '../widgets/wall_editor_sheet.dart';

class MyWallScreen extends StatelessWidget {
  const MyWallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppViewModel app = context.watch<AppViewModel>();
    final List<WallItem> items = app.sortedWallItems;
    final bool hasPinned = items.any((WallItem item) => item.isPinned);

    return ThryveTabPage(
      onAvatarTap: () => context.goToTab(ShellTab.settings),
      children: <Widget>[
        const PageHeading(
          title: 'My Wall',
          subtitle:
              'Moments, people and places that keep you focused on why '
              'you started.',
        ),
        const SizedBox(height: 20),
        CalloutCard(
          icon: Icons.visibility_outlined,
          title: "Today's vision",
          message: items.isEmpty
              ? 'Add your first image — it becomes your Home reminder.'
              : (hasPinned
                    ? 'Your pinned image is featured on Home.'
                    : 'Pin an image to feature it on Home.'),
        ),
        const SizedBox(height: 16),
        for (final WallItem item in items)
          WallCard(
            item: item,
            onTap: () => _showItem(context, item.id),
            onTogglePinned: () => app.toggleWallPinned(item.id),
          ),
        _AddTile(onTap: () => _add(context, app)),
      ],
    );
  }

  Future<void> _add(BuildContext context, AppViewModel app) async {
    final WallDraft? draft = await showWallEditor(context);
    if (draft != null) {
      app.addWallItem(
        title: draft.title,
        category: draft.category,
        image: draft.image,
        note: draft.note,
        nextStep: draft.nextStep,
      );
    }
  }

  Future<void> _showItem(BuildContext pageContext, String id) {
    return showThryveSheet<void>(
      pageContext,
      (BuildContext sheetContext) => _WallItemSheet(
        itemId: id,
        onEdit: (WallItem item) async {
          Navigator.pop(sheetContext);
          final WallDraft? draft = await showWallEditor(
            pageContext,
            initial: item,
          );
          if (draft != null && pageContext.mounted) {
            pageContext.read<AppViewModel>().updateWallItem(
              item.id,
              title: draft.title,
              category: draft.category,
              image: draft.image,
              note: draft.note,
              nextStep: draft.nextStep,
            );
          }
        },
        onRemove: (WallItem item) async {
          final bool confirmed = await confirmDestructive(
            sheetContext,
            title: 'Remove from Wall?',
            message: '"${item.title}" will be removed from your Wall.',
            confirmLabel: 'Remove',
          );
          if (confirmed && sheetContext.mounted) {
            Navigator.pop(sheetContext);
            pageContext.read<AppViewModel>().removeWallItem(item.id);
          }
        },
      ),
    );
  }
}

class _WallItemSheet extends StatelessWidget {
  const _WallItemSheet({
    required this.itemId,
    required this.onEdit,
    required this.onRemove,
  });

  final String itemId;
  final ValueChanged<WallItem> onEdit;
  final ValueChanged<WallItem> onRemove;

  @override
  Widget build(BuildContext context) {
    final AppViewModel app = context.watch<AppViewModel>();
    final WallItem? item = app.wallItems
        .where((WallItem value) => value.id == itemId)
        .firstOrNull;
    if (item == null) {
      return const SizedBox.shrink();
    }
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Hero(
              tag: 'wall-${item.id}',
              child: AppImage(
                source: item.image,
                height: 300,
                width: double.infinity,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SectionLabel(item.category, color: colors.primary),
                      const SizedBox(height: 5),
                      Text(item.title, style: text.displayMedium),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: item.isPinned ? 'Unpin from Home' : 'Pin to Home',
                  onPressed: () => app.toggleWallPinned(item.id),
                  icon: Icon(
                    item.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  ),
                ),
              ],
            ),
            if (item.note.isNotEmpty) ...<Widget>[
              const SizedBox(height: 14),
              Text(
                item.note,
                style: text.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
            if (item.nextStep.isNotEmpty) ...<Widget>[
              const SizedBox(height: 18),
              SectionLabel('Next action', color: colors.primary),
              const SizedBox(height: 6),
              Text(item.nextStep, style: text.bodyMedium),
            ],
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                Expanded(
                  child: PrimaryButton(
                    label: 'Edit',
                    icon: Icons.edit_outlined,
                    onPressed: () => onEdit(item),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.outlined(
                  tooltip: 'Remove',
                  onPressed: () => onRemove(item),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return ThryveCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, color: colors.primary, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            'ADD TO WALL',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.primary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
