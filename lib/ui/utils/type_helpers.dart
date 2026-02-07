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
      return const Color(0xFF4D88FF); // Bio-Digital Blue
    case 'image':
      return const Color(0xFF00F2AD); // Neural Teal
    case 'pdf':
      return const Color(0xFFFF4D4D); // Error Red
    case 'document':
      return const Color(0xFFFFB34D); // Data Amber
    case 'video':
      return const Color(0xFFB34DFF); // Logic Purple
    case 'social':
      return const Color(0xFFFF4D94); // Network Pink
    case 'note':
    case 'text':
      return const Color(0xFF00D2D2); // Neural Cyan
    default:
      return const Color(0xFF888888); // Neutral Data
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

/// Advanced "Living" date formatter for professional tech UI
String formatLivingDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);
  
  // Format helpers
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final timeStr = '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  final dateStr = '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year.toString().substring(2)}';
  
  if (diff.inMinutes < 1) return 'JUST NOW';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  
  if (diff.inDays < 7) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = dayNames[date.weekday - 1];
    return '${diff.inDays}d ago | $weekday $timeStr';
  }
  
  final weeks = (diff.inDays / 7).floor();
  if (weeks < 4) {
    return '${weeks}w ago | $dateStr $timeStr';
  }
  
  return '$dateStr | $timeStr';
}
