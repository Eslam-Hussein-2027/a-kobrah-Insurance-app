import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/l10n.dart';

/// Asks camera vs. gallery, then returns a downscaled image (keeps uploads under the 5 MB limit).
Future<XFile?> pickDocumentImage(BuildContext context) async {
  final l10n = context.l10n;
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l10n.camera),
            onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l10n.gallery),
            onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  if (source == null) {
    return null;
  }

  return ImagePicker().pickImage(source: source, maxWidth: 1800, imageQuality: 85);
}

Future<MultipartFile> toMultipart(XFile file) async =>
    MultipartFile.fromBytes(await file.readAsBytes(), filename: file.name);
