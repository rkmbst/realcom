import 'package:flutter/services.dart';

class HapticHelper {
  static void lightImpact() {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {
      // الصمت التام — بدون صوت أو اهتزاز بصري بديل
    }
  }

  static void mediumImpact() {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {
      // Fallback صامت
    }
  }

  static void heavyImpact() {
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {
      // Fallback صامت
    }
  }
}
