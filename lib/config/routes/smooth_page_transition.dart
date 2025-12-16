import 'package:flutter/material.dart';

/// Smooth page transition with optimized animation
/// Provides fast, smooth transitions between screens
class SmoothPageTransition extends PageRouteBuilder {
  SmoothPageTransition({
    required Widget child,
    Duration transitionDuration = const Duration(milliseconds: 250),
    Curve curve = Curves.easeOutCubic,
  }) : super(
         transitionDuration: transitionDuration,
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return SlideTransition(
             position: Tween<Offset>(
               begin: const Offset(1, 0),
               end: Offset.zero,
             ).animate(CurvedAnimation(parent: animation, curve: curve)),
             child: child,
           );
         },
       );
}

/// Fade page transition for quick transitions
class FadePageTransition extends PageRouteBuilder {
  FadePageTransition({
    required Widget child,
    Duration transitionDuration = const Duration(milliseconds: 200),
  }) : super(
         transitionDuration: transitionDuration,
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return FadeTransition(opacity: animation, child: child);
         },
       );
}

/// Scale page transition for emphasis
class ScalePageTransition extends PageRouteBuilder {
  ScalePageTransition({
    required Widget child,
    Duration transitionDuration = const Duration(milliseconds: 300),
  }) : super(
         transitionDuration: transitionDuration,
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return ScaleTransition(
             scale: Tween<double>(begin: 0.9, end: 1.0).animate(
               CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
             ),
             child: child,
           );
         },
       );
}
