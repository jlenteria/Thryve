import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../view_models/app_view_model.dart';
import '../../widgets/common_widgets.dart';

class MyWallScreen extends StatelessWidget {
  const MyWallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppViewModel app = context.watch<AppViewModel>();
    final List<WallItem> items = List<WallItem>.from(app.wallItems)
      ..sort((WallItem a, WallItem b) {
        if (a.isPinned == b.isPinned) return 0;
        return a.isPinned ? -1 : 1;
      });
    final int pinnedCount = items
        .where((WallItem item) => item.isPinned)
        .length;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          ThryveSliverHeader(avatarUrl: app.user.avatarUrl),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'My Wall',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Your visual sanctuary for growth. A collection of moments, inspirations, and milestones that keep you focused on your journey.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                ThryveCard(
                  color: AppColors.primary.withValues(alpha: 0.07),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.visibility_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'TODAY\'S VISION',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: AppColors.primary),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              pinnedCount == 0
                                  ? 'Open an image and pin what matters most today.'
                                  : 'This reminder is pinned to your dashboard focus.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...items.map(
                  (WallItem item) => _WallCard(
                    item: item,
                    onTap: () => _showWallItem(context, app, item),
                    onTogglePinned: () => app.toggleWallPinned(item.id),
                  ),
                ),
                // Add to wall
                GestureDetector(
                  onTap: () => _addToWall(context, app),
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.5),
                        style: BorderStyle.solid,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: AppColors.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'ADD TO WALL',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 1.2,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addToWall(BuildContext context, AppViewModel app) async {
    final _WallDraft? draft = await showModalBottomSheet<_WallDraft>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) => const _WallEditorDialog(),
    );
    if (draft != null) {
      app.addWallItem(
        title: draft.title,
        category: draft.category,
        imageUrl: draft.imageUrl,
        note: draft.note,
        nextStep: draft.nextStep,
      );
    }
  }

  Future<void> _editWallItem(
    BuildContext context,
    AppViewModel app,
    WallItem item,
  ) async {
    final _WallDraft? draft = await showModalBottomSheet<_WallDraft>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext context) => _WallEditorDialog(item: item),
    );
    if (draft != null) {
      app.updateWallItem(
        item.id,
        title: draft.title,
        category: draft.category,
        imageUrl: draft.imageUrl,
        note: draft.note,
        nextStep: draft.nextStep,
      );
    }
  }

  Future<void> _showWallItem(
    BuildContext pageContext,
    AppViewModel app,
    WallItem item,
  ) async {
    await showModalBottomSheet<void>(
      context: pageContext,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (BuildContext sheetContext) => Consumer<AppViewModel>(
        builder:
            (BuildContext context, AppViewModel currentApp, Widget? child) {
              final WallItem current = currentApp.wallItems.firstWhere(
                (WallItem value) => value.id == item.id,
                orElse: () => item,
              );
              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Hero(
                        tag: 'wall-${current.id}',
                        child: NetworkImageSafe(
                          url: current.imageUrl,
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
                                SectionLabel(
                                  current.category,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  current.title,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.displayMedium,
                                ),
                              ],
                            ),
                          ),
                          IconButton.filledTonal(
                            tooltip: current.isPinned
                                ? 'Unpin'
                                : 'Pin to focus',
                            onPressed: () =>
                                currentApp.toggleWallPinned(current.id),
                            icon: Icon(
                              current.isPinned
                                  ? Icons.push_pin
                                  : Icons.push_pin_outlined,
                            ),
                          ),
                        ],
                      ),
                      if (current.note.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 14),
                        Text(
                          current.note,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: AppColors.onSurfaceVariant,
                                height: 1.5,
                              ),
                        ),
                      ],
                      if (current.nextStep.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 18),
                        Text(
                          'NEXT ACTION',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 1.1,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          current.nextStep,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: PrimaryButton(
                              label: 'Edit',
                              icon: Icons.edit_outlined,
                              onPressed: () {
                                Navigator.pop(sheetContext);
                                Future<void>.delayed(
                                  Duration.zero,
                                  () =>
                                      _editWallItem(pageContext, app, current),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton.outlined(
                            tooltip: 'Remove',
                            onPressed: () {
                              Navigator.pop(sheetContext);
                              app.removeWallItem(current.id);
                            },
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
      ),
    );
  }
}

class _WallCard extends StatelessWidget {
  final WallItem item;
  final VoidCallback onTap;
  final VoidCallback onTogglePinned;
  const _WallCard({
    required this.item,
    required this.onTap,
    required this.onTogglePinned,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              Hero(
                tag: 'wall-${item.id}',
                child: NetworkImageSafe(
                  url: item.imageUrl,
                  height: 200,
                  width: double.infinity,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton.filledTonal(
                  tooltip: item.isPinned ? 'Unpin' : 'Pin to focus',
                  onPressed: onTogglePinned,
                  icon: Icon(
                    item.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  ),
                ),
              ),
              // Gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.65),
                      ],
                      stops: const [0.45, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.category,
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WallDraft {
  const _WallDraft({
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.note,
    required this.nextStep,
  });

  final String title;
  final String category;
  final String imageUrl;
  final String note;
  final String nextStep;
}

class _WallEditorDialog extends StatefulWidget {
  const _WallEditorDialog({this.item});

  final WallItem? item;

  @override
  State<_WallEditorDialog> createState() => _WallEditorDialogState();
}

class _WallEditorDialogState extends State<_WallEditorDialog> {
  static const List<String> _standardCategories = <String>[
    'Inspiration',
    'Family',
    'Relationships',
    'Personal Growth',
    'Career',
    'Business',
    'Financial',
    'Health & Fitness',
    'Education',
    'Travel',
    'Nature',
    'Architecture',
    'Home',
    'Workspace',
    'Lifestyle',
    'Creativity',
    'Spirituality',
    'Milestone',
    'Quote',
    'Other',
  ];

  late final TextEditingController _title;
  late final TextEditingController _note;
  late final TextEditingController _nextStep;
  late final TextEditingController _url;
  late final List<String> _categories;
  late String _category;
  late String _imageUrl;
  bool _isPicking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final WallItem? item = widget.item;
    _title = TextEditingController(text: item?.title ?? '');
    _category = item?.category.trim().isNotEmpty == true
        ? item!.category.trim()
        : 'Inspiration';
    _categories = <String>[
      ..._standardCategories,
      if (!_standardCategories.contains(_category)) _category,
    ];
    _note = TextEditingController(text: item?.note ?? '');
    _nextStep = TextEditingController(text: item?.nextStep ?? '');
    _imageUrl = item?.imageUrl ?? '';
    _url = TextEditingController(
      text: _imageUrl.startsWith('data:image/') ? '' : _imageUrl,
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    _nextStep.dispose();
    _url.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() {
      _isPicking = true;
      _error = null;
    });
    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 82,
      );
      if (picked != null) {
        final List<int> bytes = await picked.readAsBytes();
        final String mimeType = picked.mimeType ?? 'image/jpeg';
        if (mounted) {
          setState(() {
            _imageUrl = 'data:$mimeType;base64,${base64Encode(bytes)}';
            _url.clear();
          });
        }
      }
    } on Object {
      if (mounted) {
        setState(() => _error = 'Could not open the photo library.');
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  void _save() {
    final String title = _title.text.trim();
    final String pastedUrl = _url.text.trim();
    final String image = pastedUrl.isNotEmpty ? pastedUrl : _imageUrl;
    if (title.isEmpty || image.isEmpty) {
      setState(() => _error = 'Add a title and choose an image.');
      return;
    }
    Navigator.pop(
      context,
      _WallDraft(
        title: title,
        category: _category,
        imageUrl: image,
        note: _note.text.trim(),
        nextStep: _nextStep.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPreview = _imageUrl.isNotEmpty;
    return ThryveBottomSheet(
      title: widget.item == null ? 'Add to your wall' : 'Edit inspiration',
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (hasPreview) ...<Widget>[
                NetworkImageSafe(
                  url: _imageUrl,
                  width: double.infinity,
                  height: 150,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton.icon(
                onPressed: _isPicking ? null : _pickImage,
                icon: _isPicking
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.photo_library_outlined),
                label: Text(hasPreview ? 'Change image' : 'Upload image'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _url,
                keyboardType: TextInputType.url,
                onSubmitted: (String value) {
                  if (value.trim().isNotEmpty) {
                    setState(() => _imageUrl = value.trim());
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Or paste an image URL',
                  suffixIcon: IconButton(
                    tooltip: 'Preview URL',
                    onPressed: () {
                      if (_url.text.trim().isNotEmpty) {
                        setState(() => _imageUrl = _url.text.trim());
                      }
                    },
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _title,
                autofocus: widget.item == null,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                isExpanded: true,
                menuMaxHeight: 360,
                items: _categories
                    .map(
                      (String category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(
                          category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (String? value) {
                  if (value != null) setState(() => _category = value);
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _note,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Why it matters (optional)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nextStep,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Next action (optional)',
                  hintText: 'One small thing you can do next',
                ),
              ),
              if (_error != null) ...<Widget>[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isPicking ? null : _save,
          child: Text(widget.item == null ? 'Add' : 'Save changes'),
        ),
      ],
    );
  }
}
