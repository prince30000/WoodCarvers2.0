import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Wood Carvers Signature Page Transition
/// Features a swift, artisanal organic edge reveal that retracts smoothly
class WoodCarverPageTransition extends PageRouteBuilder {
  final Widget child;

  WoodCarverPageTransition({required this.child, super.settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 380),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final mediaQuery = MediaQuery.maybeOf(context);
            if (mediaQuery != null && mediaQuery.disableAnimations) {
              return child;
            }

            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            // Subtle organic edge slide and fade
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.02, 0),
              end: Offset.zero,
            ).animate(curvedAnimation);

            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(curvedAnimation);

            return Stack(
              children: [
                FadeTransition(
                  opacity: fadeAnimation,
                  child: SlideTransition(
                    position: slideAnimation,
                    child: child,
                  ),
                ),
                // Subtle organic edge reveal accent (retracts as transition completes)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: FadeTransition(
                    opacity: TweenSequence<double>([
                      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.8), weight: 30),
                      TweenSequenceItem(tween: Tween(begin: 0.8, end: 0.0), weight: 70),
                    ]).animate(curvedAnimation),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.antiqueGold,
                            AppColors.naturalWood,
                            AppColors.espresso,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
}

/// Carved Reveal Animation wrapper for product cards and hero banners
class CarvedRevealWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const CarvedRevealWidget({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 450),
  });

  @override
  State<CarvedRevealWidget> createState() => _CarvedRevealWidgetState();
}

class _CarvedRevealWidgetState extends State<CarvedRevealWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
