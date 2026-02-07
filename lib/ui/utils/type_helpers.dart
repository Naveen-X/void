// lib/ui/utils/type_helpers.dart
// Shared utility functions for content type handling

import 'package:flutter/material.dart';

/// Checks if a path is a local file path
bool isLocalPath(String path) {
  return path.startsWith('/') || path.startsWith('file://');
}

/// Checks if the type represents a file-based content
bool isFileType(String type) {
  return type == 'image' ||
      type == 'pdf' ||
      type == 'document' ||
      type == 'file' ||
      type == 'video';
}

/// Returns appropriate icon for content type
IconData getIconForType(String type) {
  switch (type) {
    case 'link':
      return Icons.link;
    case 'image':
      return Icons.image_rounded;
    case 'pdf':
      return Icons.picture_as_pdf_rounded;
    case 'document':
      return Icons.description_rounded;
    case 'file':
      return Icons.insert_drive_file_rounded;
    case 'video':
      return Icons.video_file_rounded;
    case 'social':
      return Icons.share_rounded;
    default:
      return Icons.notes_rounded;
  }
}

/// Returns accent color for content type
Color getColorForType(String type) {
  switch (type) {
    case 'link':
      return Colors.blueAccent;
    case 'image':
      return Colors.tealAccent;
    case 'pdf':
      return Colors.redAccent;
    case 'document':
      return Colors.orangeAccent;
    case 'video':
      return Colors.purpleAccent;
    case 'social':
      return Colors.pinkAccent;
    default:
      return Colors.white54;
  }
}

/// Formats a date into a human-readable relative string
String formatRelativeDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inDays == 0) return 'Today';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${date.day}/${date.month}';
}

/// Returns time ago string for a date
String getTimeAgo(DateTime date) {
  final duration = DateTime.now().difference(date);
  if (duration.inMinutes < 1) return 'Just now';
  if (duration.inMinutes < 60) return '${duration.inMinutes}m ago';
  if (duration.inHours < 24) return '${duration.inHours}h ago';
  if (duration.inDays < 7) return '${duration.inDays}d ago';
  return '${date.day}/${date.month}/${date.year}';
}
