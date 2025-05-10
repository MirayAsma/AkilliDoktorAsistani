import 'package:flutter/material.dart';
import '../widgets/heart_page_transition.dart';

/// Tüm uygulama içinde sayfa geçişlerinde kalp animasyonu kullanmak için yardımcı sınıf
class NavigationHelper {
  /// Normal Navigator.push yerine bu metodu kullanarak kalp animasyonlu geçiş yapabilirsiniz
  static Future<T?> pushWithHeartAnimation<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).push<T>(
      HeartPageTransition(page: page),
    );
  }

  /// Normal Navigator.pushReplacement yerine bu metodu kullanarak kalp animasyonlu geçiş yapabilirsiniz
  static Future<T?> pushReplacementWithHeartAnimation<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).pushReplacement<T, T>(
      HeartPageTransition(page: page),
    );
  }

  /// Herhangi bir sayfaya geçiş yaparken bu metodu kullanın
  static Route<T> createHeartTransition<T>(Widget page) {
    return HeartPageTransition(page: page);
  }
}
