import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Stores user-picked images as files in the app documents directory.
///
/// References are saved as `local:<file name>` rather than absolute paths,
/// because iOS changes the app container path between installs and updates.
/// Earlier builds stored base64 `data:` URIs; those still resolve.
abstract final class ImageStore {
  static const String _scheme = 'local:';
  static const Uuid _uuid = Uuid();
  static String? _directory;

  static Future<void> initialize() async {
    if (kIsWeb || _directory != null) {
      return;
    }
    try {
      final Directory docs = await getApplicationDocumentsDirectory();
      final Directory images = Directory('${docs.path}/images');
      if (!images.existsSync()) {
        await images.create(recursive: true);
      }
      _directory = images.path;
    } on Object catch (error) {
      debugPrint('Thryve: image storage unavailable ($error).');
    }
  }

  /// Opens the gallery and returns a reference to the stored copy, or null
  /// if the user cancelled.
  static Future<String?> pickFromGallery({double maxDimension = 1600}) async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: maxDimension,
      maxHeight: maxDimension,
      imageQuality: 82,
    );
    if (picked == null) {
      return null;
    }
    final Uint8List bytes = await picked.readAsBytes();
    final String? directory = _directory;
    if (directory == null) {
      // Web / no filesystem: fall back to an inline data URI.
      return 'data:${picked.mimeType ?? 'image/jpeg'};base64,'
          '${base64Encode(bytes)}';
    }
    final String name = '${_uuid.v4()}.jpg';
    await File('$directory/$name').writeAsBytes(bytes, flush: true);
    return '$_scheme$name';
  }

  /// Deletes a stored image. Remote URLs and data URIs are ignored.
  static Future<void> delete(String? ref) async {
    final File? file = _fileFor(ref);
    if (file != null && file.existsSync()) {
      await file.delete();
    }
  }

  static bool isRemote(String ref) =>
      ref.startsWith('http://') || ref.startsWith('https://');

  static ImageProvider<Object>? provider(String? ref) {
    if (ref == null || ref.isEmpty) {
      return null;
    }
    if (ref.startsWith('data:image/')) {
      try {
        return MemoryImage(base64Decode(ref.substring(ref.indexOf(',') + 1)));
      } on FormatException {
        return null;
      }
    }
    if (ref.startsWith(_scheme)) {
      final File? file = _fileFor(ref);
      return file == null ? null : FileImage(file);
    }
    return NetworkImage(ref);
  }

  static File? _fileFor(String? ref) {
    final String? directory = _directory;
    if (ref == null || !ref.startsWith(_scheme) || directory == null) {
      return null;
    }
    return File('$directory/${ref.substring(_scheme.length)}');
  }
}
