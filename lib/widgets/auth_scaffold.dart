import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_controls.dart';

class AuthScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showBackButton;

  const AuthScaffold({
    super.key,
    required this.child,
    this.title,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0A0E21),
                    const Color(0xFF1A1B3A),
                    const Color(0xFF2D1B69),
                    const Color(0xFF0A192F),
                  ]
                : [
                    const Color(0xFFE3F2FD),
                    const Color(0xFFBBDEFB),
                    const Color(0xFF90CAF9),
                    const Color(0xFF64B5F6),
                  ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              if (showBackButton)
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_forward),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.3),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              
              // App Controls
              Positioned(
                top: 16,
                right: 16,
                child: const AppControls(),
              ),
              
              if (title != null)
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      title!,
                      style: GoogleFonts.tajawal(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              
              child,
            ],
          ),
        ),
      ),
      ),
    );
  }
}