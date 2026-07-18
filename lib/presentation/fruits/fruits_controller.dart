import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/fruit_model.dart';
import '../../data/datasources/fruits_data.dart';
import '../../services/progress_service.dart';
import '../../services/tts_service.dart';
import 'widgets/fruit_detail_sheet.dart';

class FruitsController extends GetxController {
  final ProgressService _progress = ProgressService.to;

  RxSet<String> get visitedFruits => _progress.visitedFruits;

  late final List<FruitModel> fruitsList;
  late final List<FruitModel> vegetablesList;

  @override
  void onInit() {
    super.onInit();
    
    // Separate fruits and vegetables
    fruitsList = FruitsData.items.where((item) => !item.isVegetable).toList();
    vegetablesList = FruitsData.items.where((item) => item.isVegetable).toList();
  }

  void onFruitTap(FruitModel item) {
    if (!visitedFruits.contains(item.name)) {
      _progress.addVisitedFruit(item.name);
    }
    
    showFruitDetail(item);
  }

  void speak(String text) {
    TtsService.to.speak(text);
  }

  void showFruitDetail(FruitModel item) {
    Get.bottomSheet(
      FruitDetailSheet(item: item),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
    );
  }
}
