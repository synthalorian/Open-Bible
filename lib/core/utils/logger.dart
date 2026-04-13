import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Production-safe logger. No-op in release builds.
void logDebug(String message) {
  if (kDebugMode) {
    developer.log(message, name: 'OpenBible');
  }
}
