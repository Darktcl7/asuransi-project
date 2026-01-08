// lib/utils/snackbar_helper.dart
import 'package:flutter/material.dart';

class SnackbarHelper {
  // Success snackbar - TOP position
  static void showSuccess(BuildContext context, String message) {
    _showTopSnackbar(
      context,
      message: message,
      icon: Icons.check_circle,
      backgroundColor: Colors.green.shade600,
    );
  }

  // Error snackbar - TOP position
  static void showError(BuildContext context, String message) {
    _showTopSnackbar(
      context,
      message: message,
      icon: Icons.error_outline,
      backgroundColor: Colors.red.shade600,
      duration: const Duration(seconds: 4),
    );
  }

  // Warning snackbar - TOP position
  static void showWarning(BuildContext context, String message) {
    _showTopSnackbar(
      context,
      message: message,
      icon: Icons.warning_amber,
      backgroundColor: Colors.orange.shade600,
    );
  }

  // Info snackbar - TOP position
  static void showInfo(BuildContext context, String message) {
    _showTopSnackbar(
      context,
      message: message,
      icon: Icons.info_outline,
      backgroundColor: Colors.blue.shade600,
    );
  }

  // Internal method to show top snackbar using overlay
  static void _showTopSnackbar(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _TopSnackbar(
        message: message,
        icon: icon,
        backgroundColor: backgroundColor,
        duration: duration,
        onDismiss: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }

  // Loading snackbar - TOP position
  static OverlayEntry? _loadingOverlay;
  
  static void showLoading(BuildContext context, String message) {
    hideLoading(); // Remove any existing loading
    
    final overlay = Overlay.of(context);
    _loadingOverlay = OverlayEntry(
      builder: (context) => _TopSnackbar(
        message: message,
        icon: Icons.hourglass_empty,
        backgroundColor: Colors.indigo.shade600,
        duration: const Duration(days: 365),
        isLoading: true,
        onDismiss: () {},
      ),
    );
    overlay.insert(_loadingOverlay!);
  }

  // Hide loading snackbar
  static void hideLoading() {
    _loadingOverlay?.remove();
    _loadingOverlay = null;
  }

  // Hide current snackbar (for compatibility)
  static void hide(BuildContext context) {
    hideLoading();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}

// Top Snackbar Widget
class _TopSnackbar extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Duration duration;
  final VoidCallback onDismiss;
  final bool isLoading;

  const _TopSnackbar({
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.duration,
    required this.onDismiss,
    this.isLoading = false,
  });

  @override
  State<_TopSnackbar> createState() => _TopSnackbarState();
}

class _TopSnackbarState extends State<_TopSnackbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    if (!widget.isLoading) {
      Future.delayed(widget.duration, () {
        if (mounted) {
          _dismiss();
        }
      });
    }
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: widget.backgroundColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (widget.isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    Icon(widget.icon, color: Colors.white, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (!widget.isLoading)
                    GestureDetector(
                      onTap: _dismiss,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
