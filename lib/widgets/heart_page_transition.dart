import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Kalp animasyonlu sayfa geçişi sağlayan özel route sınıfı
class HeartPageTransition<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  HeartPageTransition({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 1500),
          reverseTransitionDuration: const Duration(milliseconds: 1000),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return Stack(
              children: [
                FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                // Kalp animasyonu
                AnimatedHeartIcon(animation: animation),
              ],
            );
          },
        );
}

class AnimatedHeartIcon extends StatelessWidget {
  final Animation<double> animation;
  
  const AnimatedHeartIcon({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    // Ekran boyutlarını al
    final size = MediaQuery.of(context).size;
    
    // Animasyon değerleri - daha büyük ve belirgin
    final sizeAnimation = Tween<double>(begin: 80, end: 200).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );
    
    final opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
    
    final positionAnimation = Tween<Offset>(
      begin: Offset(size.width / 2 - 25, size.height / 2 - 25),
      end: Offset(size.width / 2 - 75, size.height / 2 - 75),
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );
    
    final rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: animation,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: opacityAnimation.value,
          child: Transform.translate(
            offset: positionAnimation.value,
            child: Transform.rotate(
              angle: rotationAnimation.value,
              child: Icon(
                Icons.favorite,
                color: Colors.red,
                size: sizeAnimation.value,
              ),
            ),
          ),
        );
      },
    );
  }
}
