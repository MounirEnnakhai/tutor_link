import 'package:flutter/material.dart';

// ─── BuildContext extensions ──────────────────────────────────────────────────
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  void showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<bool?> showConfirmDialog({
    required String title,
    required String content,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: this,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: isDangerous
                ? ElevatedButton.styleFrom(backgroundColor: Colors.red)
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}

// ─── String extensions ────────────────────────────────────────────────────────
extension StringExtensions on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get titleCase => split(' ').map((w) => w.capitalize).join(' ');

  String get initials {
    final parts = trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(this);
  }

  bool get isValidPhone {
    return RegExp(r'^\+?[0-9]{8,15}$').hasMatch(this);
  }

  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}

// ─── DateTime extensions ──────────────────────────────────────────────────────
extension DateTimeExtensions on DateTime {
  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).round()}w ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).round()}mo ago';
    return '${(diff.inDays / 365).round()}y ago';
  }

  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[month - 1]} $day, $year';
  }

  String get formattedDateTime {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$formattedDate at $h:$m';
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

// ─── Double extensions ────────────────────────────────────────────────────────
extension DoubleExtensions on double {
  String get formatPrice => toStringAsFixed(0);

  String formatCurrency([String currency = 'MAD']) =>
      '${toStringAsFixed(0)} $currency';
}

// ─── List extensions ──────────────────────────────────────────────────────────
extension ListExtensions<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;

  List<T> safeSublist(int start, [int? end]) {
    final e = end == null ? length : end.clamp(0, length);
    final s = start.clamp(0, e);
    return sublist(s, e);
  }
}
