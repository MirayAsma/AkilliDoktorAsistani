import 'package:flutter/material.dart';
import 'dart:async';

/// Ekranın üstünde aşağı doğru kayan bildirim gösterir
class NotificationOverlay extends StatefulWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onTap;
  final Duration duration;

  const NotificationOverlay({
    Key? key,
    required this.title,
    required this.message,
    this.icon = Icons.notifications,
    this.backgroundColor = const Color(0xFF00BCD4),
    this.textColor = Colors.white,
    this.onTap,
    this.duration = const Duration(seconds: 4),
  }) : super(key: key);

  /// Bildirim göstermek için statik metod
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    IconData icon = Icons.notifications,
    Color backgroundColor = const Color(0xFF00BCD4),
    Color textColor = Colors.white,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) async {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => NotificationOverlay(
        title: title,
        message: message,
        icon: icon,
        backgroundColor: backgroundColor,
        textColor: textColor,
        onTap: onTap,
        duration: duration,
      ),
    );

    overlay.insert(overlayEntry);

    // Belirli süre sonra kaldır
    await Future.delayed(duration);
    overlayEntry.remove();
  }

  @override
  State<NotificationOverlay> createState() => _NotificationOverlayState();
}

class _NotificationOverlayState extends State<NotificationOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    // Otomatik kapanma için zamanlayıcı
    Future.delayed(widget.duration - const Duration(milliseconds: 500), () {
      if (mounted) {
        _controller.reverse();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: widget.backgroundColor,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          widget.icon,
                          color: widget.textColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  color: widget.textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.message,
                                style: TextStyle(
                                  color: widget.textColor.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: widget.textColor.withOpacity(0.7),
                            size: 20,
                          ),
                          onPressed: () {
                            _controller.reverse().then((_) {
                              if (context.mounted) {
                                Navigator.of(context, rootNavigator: true).pop();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
