import 'package:flutter/material.dart';

/// ---------------------------
/// Admin Palette (white/black/gray + custom HEX for statuses)
/// ---------------------------
class AppColors {
  static const bg = Color(0xFFF5F6F8); // page background
  static const surface = Color(0xFFFFFFFF); // panels
  static const border = Color(0xFFE5E7EB); // subtle border
  static const text = Color(0xFF111827); // gray-900
  static const textMuted = Color(0xFF6B7280); // gray-500
  static const borderColro = Color(0xFF6366F1);

  // Status colors (custom HEX, not Material constants)
  static const activeText = Color(0xFF065F46); // emerald-800
  static const activeBg = Color(0xFFD1FAE5); // emerald-100
  static const inactiveText = Color(0xFF7F1D1D); // red-900
  static const inactiveBg = Color(0xFFFEE2E2); // red-100

  // Neutrals for icons
  static const icon = Color(0xFF374151); // gray-700
  static const iconMuted = Color(0xFF9CA3AF); // gray-400
}
