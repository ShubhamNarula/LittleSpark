import 'package:get/get.dart';
import '../../data/models/badge_model.dart';
import '../../data/datasources/badges_data.dart';
import '../../services/progress_service.dart';

class RewardsController extends GetxController {
  final ProgressService _progress = ProgressService.to;

  RxInt get totalStars => _progress.totalStarsRx;
  RxSet<String> get unlockedBadges => _progress.unlockedBadges;

  final List<BadgeModel> badges = BadgesData.badges;
}
