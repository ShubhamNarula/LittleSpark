import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/color_item_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/tts_service.dart';
import '../../../core/utils/haptic_util.dart';
import '../colors_shapes_controller.dart';

class ColorSwatchCard extends StatelessWidget {
  final ColorItemModel colorItem;

  const ColorSwatchCard({
    Key? key,
    required this.colorItem,
  }) : super(key: key);

  String _getEmojiLabel(String emoji) {
    const map = {
      '🍎': 'Apple', '🚗': 'Car', '🍓': 'Strawberry',
      '🍊': 'Orange', '🦁': 'Lion', '🥕': 'Carrot',
      '🍌': 'Banana', '☀️': 'Sun', '🍋': 'Lemon',
      '🐸': 'Frog', '🥦': 'Broccoli', '🍉': 'Melon',
      '🐳': 'Whale', '🫐': 'Berry', '👖': 'Jeans',
      '🍇': 'Grapes', '🪼': 'Jellyfish', '🍆': 'Eggplant',
      '🦩': 'Flamingo', '🍩': 'Donut', '🐷': 'Pig',
      '🐻': 'Bear', '🥥': 'Coconut', '🥔': 'Potato',
      '🐈‍⬛': 'Cat', '🎩': 'Hat', '🎱': 'Ball',
      '☁️': 'Cloud', '🥛': 'Milk', '⚪': 'Circle',
      '🐘': 'Elephant', '🐨': 'Koala', '🪨': 'Rock',
      '🦆': 'Duck', '🦚': 'Peacock', '🧪': 'Flask'
    };
    return map[emoji] ?? 'Item';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ColorsShapesController>();

    return GestureDetector(
      onTap: () {
        HapticUtil.light();
        controller.onColorTap(colorItem);
        
        // Full screen flash color dialog
        showDialog(
          context: context,
          barrierColor: colorItem.color.withOpacity(0.85),
          builder: (_) => GestureDetector(
            onTap: () => Get.back(),
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: SingleChildScrollView(
                  child: ColorDetailSheet(
                    colorItem: colorItem,
                    getEmojiLabel: _getEmojiLabel,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: Container(
        height: 130.0,
        decoration: BoxDecoration(
          color: colorItem.color,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: colorItem.color.withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bubbly lighter center dot
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  "✨",
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            
            // Name Label
            Text(
              colorItem.name,
              style: AppTextStyles.bodyMediumBold.copyWith(
                color: Colors.white,
                shadows: const [
                  Shadow(
                    color: Colors.black45,
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorDetailSheet extends StatelessWidget {
  final ColorItemModel colorItem;
  final String Function(String) getEmojiLabel;

  const ColorDetailSheet({
    Key? key,
    required this.colorItem,
    required this.getEmojiLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.bgMid.withOpacity(0.95),
        borderRadius: BorderRadius.circular(28.0),
        border: Border.all(color: Colors.white30),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Color Title
          Text(
            colorItem.name,
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 56.0,
              color: colorItem.color,
              shadows: const [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),

          // Row of Emojis
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: colorItem.emojiExamples.map((emoji) {
              return Column(
                children: [
                  Container(
                    width: 68.0,
                    height: 68.0,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 36.0),
                      ),
                    ),
                  )
                      .animate()
                      .scale(duration: 400.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 6.0),
                  Text(
                    getEmojiLabel(emoji),
                    style: AppTextStyles.bodySmallBold.copyWith(
                      fontSize: 14.0, // Enforce 14sp minimum
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 24.0),

          // Challenge box
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              colorItem.roomChallenge,
              style: AppTextStyles.bodyMediumBold.copyWith(
                fontSize: 16.0,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24.0),

          // Hear voice button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticUtil.light();
                TtsService.to.speak(colorItem.name);
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("🔊", style: TextStyle(fontSize: 20.0)),
                  SizedBox(width: 8.0),
                  Text("Hear it!"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
