class WallItem {
  const WallItem({
    required this.id,
    required this.title,
    required this.category,
    required this.image,
    this.note = '',
    this.nextStep = '',
    this.isPinned = false,
  });

  factory WallItem.fromJson(Map<String, dynamic> json) => WallItem(
    id: json['id'] as String,
    title: json['title'] as String,
    category: json['category'] as String? ?? 'Inspiration',
    image: (json['image'] ?? json['imageUrl']) as String? ?? '',
    note: json['note'] as String? ?? '',
    nextStep: json['nextStep'] as String? ?? '',
    isPinned: json['isPinned'] as bool? ?? false,
  );

  final String id;
  final String title;
  final String category;

  /// Image reference understood by `AppImage` (local file, data URI or URL).
  final String image;
  final String note;
  final String nextStep;
  final bool isPinned;

  WallItem copyWith({
    String? title,
    String? category,
    String? image,
    String? note,
    String? nextStep,
    bool? isPinned,
  }) => WallItem(
    id: id,
    title: title ?? this.title,
    category: category ?? this.category,
    image: image ?? this.image,
    note: note ?? this.note,
    nextStep: nextStep ?? this.nextStep,
    isPinned: isPinned ?? this.isPinned,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'category': category,
    'image': image,
    'note': note,
    'nextStep': nextStep,
    'isPinned': isPinned,
  };
}
