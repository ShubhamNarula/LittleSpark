import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../../../core/theme/app_colors.dart';

class ConfettiOverlayWidget extends StatefulWidget {
  const ConfettiOverlayWidget({Key? key}) : super(key: key);

  @override
  State<ConfettiOverlayWidget> createState() => ConfettiOverlayWidgetState();
}

class ConfettiOverlayWidgetState extends State<ConfettiOverlayWidget> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void startCelebration() {
    _confettiController.stop();
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        colors: const [
          AppColors.gold,
          AppColors.coral,
          AppColors.mint,
          AppColors.lavender,
          AppColors.skyBlue,
        ],
      ),
    );
  }
}
