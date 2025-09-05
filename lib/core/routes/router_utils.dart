// lib/core/utils/router_utils.dart
// A tiny, reusable helper for Flutter Web path/hash routing without a router package.

import 'dart:async';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

class WebPathRouter {
  StreamSubscription<html.PopStateEvent>? _pop;
  StreamSubscription<html.Event>? _hash;
  bool _writing = false;

  bool get isWeb => kIsWeb;
  bool get useHash =>
      isWeb && (html.window.location.hash.isNotEmpty);

  String normalize(String path) {
    var p = path.trim().toLowerCase();
    if (p.isEmpty) return '/';
    if (p.length > 1 && p.endsWith('/')) p = p.substring(0, p.length - 1);
    return p;
    }  String read() {
    if (!isWeb) return '/';
    final loc = html.window.location;
    final raw = useHash
        ? (loc.hash.isNotEmpty == true ? loc.hash.substring(1) : '/')
        : (loc.pathname ?? '/');
    return normalize(raw);
  }
  void write(String path, {bool replace = false}) {
    if (!isWeb) return;
    final normalized = normalize(path);
    final target = useHash ? '#$normalized' : normalized;

    // Avoid redundant writes
    final current = useHash
        ? (html.window.location.hash)
        : (html.window.location.pathname ?? '');
    if ((useHash ? '#$normalized' : normalized) == current) return;

    _writing = true;
    if (replace) {
      html.window.history.replaceState(null, '', target);
    } else {
      html.window.history.pushState(null, '', target);
    }
    // Defer unmark to next frame to absorb cascaded listeners
    Future.microtask(() {
      _writing = false;
    });
  }

  /// Subscribe to browser navigation (back/forward & hash changes).
  /// Callback should re-read `read()` and react accordingly.
  void addListeners(void Function() onNavigate) {
    if (!isWeb) return;
    _pop = html.window.onPopState.listen((_) {
      if (_writing) return;
      onNavigate();
    });
    _hash = html.window.onHashChange.listen((_) {
      if (_writing) return;
      onNavigate();
    });
  }

  bool get isWriting => _writing;

  void dispose() {
    _hash?.cancel();
    _pop?.cancel();
  }
}
