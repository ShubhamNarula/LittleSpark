import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/haptic_util.dart';
import 'bouncy_button.dart';

class GradientAppBar extends StatelessWidget {
  final String title;
  final List<Color> gradient;
  final Widget? trailing;
  final bool showLeading;

  const GradientAppBar({
    Key? key,
    required this.title,
    required this.gradient,
    this.trailing,
    this.showLeading = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Container(
      height: 100.0 + statusBarHeight,
      padding: EdgeInsets.only(
        top: statusBarHeight + 8.0,
        bottom: 12.0,
        left: 16.0,
        right: 16.0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28.0),
          bottomRight: Radius.circular(28.0),
        ),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button / Left Spacer
          SizedBox(
            width: 72.0,
            child: showLeading
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: BouncyButton(
                        onTap: () {
                          HapticUtil.light();
                          Get.back();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20.0,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          
          // Title
          Expanded(
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'FredokaOne',
                  fontSize: 24.0,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.5,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 4.0,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          
          // Trailing Action Widget / Right Spacer
          SizedBox(
            width: 72.0,
            child: trailing != null
                ? Align(
                    alignment: Alignment.centerRight,
                    child: trailing!,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
