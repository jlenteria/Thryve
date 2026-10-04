import 'package:flutter/material.dart';

import '../../../core/services/image_store.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/sheets.dart';
import '../../../data/models/wall_item.dart';

class WallDraft {
  const WallDraft({
    required this.title,
    required this.category,
    required this.image,
    required this.note,
    required this.nextStep,
  });

  final String title;
  final String category;
  final String image;
  final String note;
  final String nextStep;
}

Future<WallDraft?> showWallEditor(BuildContext context, {WallItem? initial}) =>
    showThryveSheet<WallDraft>(
      context,
      (BuildContext context) => _WallEditorSheet(initial: initial),
    );

class _WallEditorSheet extends StatefulWidget {
  const _WallEditorSheet({this.initial});

  final WallItem? initial;

  @override
  State<_WallEditorSheet> createState() => _WallEditorSheetState();
}

class _WallEditorSheetState extends State<_WallEditorSheet> {
  static const List<String> _categories = <String>[
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
  late final List<String> _options;
  late String _category;
  late String _image;

  /// A newly picked file that hasn't been saved yet; deleted if the sheet
  /// is dismissed or another image replaces it.
  String? _unsavedPick;
  bool _saved = false;
  bool _isPicking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final WallItem? item = widget.initial;
    _title = TextEditingController(text: item?.title ?? '');
    _note = TextEditingController(text: item?.note ?? '');
    _nextStep = TextEditingController(text: item?.nextStep ?? '');
    _image = item?.image ?? '';
    _url = TextEditingController(
      text: ImageStore.isRemote(_image) ? _image : '',
    );
    _category = item?.category ?? _categories.first;
    _options = <String>[
      ..._categories,
      if (!_categories.contains(_category)) _category,
    ];
  }

  @override
  void dispose() {
    if (!_saved) {
      ImageStore.delete(_unsavedPick);
    }
    _title.dispose();
    _note.dispose();
    _nextStep.dispose();
    _url.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    setState(() {
      _isPicking = true;
      _error = null;
    });
    try {
      final String? ref = await ImageStore.pickFromGallery();
      if (ref != null && mounted) {
        await ImageStore.delete(_unsavedPick);
        setState(() {
          _unsavedPick = ref;
          _image = ref;
          _url.clear();
        });
      }
    } on Object {
      if (mounted) {
        setState(() => _error = 'Could not open the photo library.');
      }
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  void _usePastedUrl() {
    final String url = _url.text.trim();
    if (!ImageStore.isRemote(url)) {
      setState(() => _error = 'Paste a link that starts with http(s)://');
      return;
    }
    setState(() {
      _image = url;
      _error = null;
    });
  }

  void _submit() {
    final String pasted = _url.text.trim();
    final String image = ImageStore.isRemote(pasted) ? pasted : _image;
    if (_title.text.trim().isEmpty || image.isEmpty) {
      setState(() => _error = 'Add a title and choose an image.');
      return;
    }
    if (image != _unsavedPick) {
      ImageStore.delete(_unsavedPick);
    }
    _saved = true;
    Navigator.pop(
      context,
      WallDraft(
        title: _title.text.trim(),
        category: _category,
        image: image,
        note: _note.text.trim(),
        nextStep: _nextStep.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = _image.isNotEmpty;
    return ThryveBottomSheet(
      title: widget.initial == null ? 'Add to your Wall' : 'Edit inspiration',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (hasImage) ...<Widget>[
            AppImage(
              source: _image,
              width: double.infinity,
              height: 150,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 12),
          ],
          OutlinedButton.icon(
            onPressed: _isPicking ? null : _pick,
            icon: _isPicking
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.photo_library_outlined),
            label: Text(hasImage ? 'Change photo' : 'Choose a photo'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _url,
            keyboardType: TextInputType.url,
            onSubmitted: (_) => _usePastedUrl(),
            decoration: InputDecoration(
              labelText: 'Or paste an image link',
              suffixIcon: IconButton(
                tooltip: 'Preview link',
                onPressed: _usePastedUrl,
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            autofocus: widget.initial == null,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            isExpanded: true,
            menuMaxHeight: 360,
            items: <DropdownMenuItem<String>>[
              for (final String category in _options)
                DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                ),
            ],
            onChanged: (String? value) {
              if (value != null) {
                setState(() => _category = value);
              }
            },
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Why it matters (optional)',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nextStep,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Next action (optional)',
              hintText: 'One small thing you can do next',
            ),
          ),
          if (_error != null) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isPicking ? null : _submit,
          child: Text(widget.initial == null ? 'Add' : 'Save changes'),
        ),
      ],
    );
  }
}
