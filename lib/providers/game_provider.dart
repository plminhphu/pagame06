import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pagame06/models/crop_model.dart';
import 'package:pagame06/utils/sounds.dart';
import '../models/plot_model.dart';

class GameProvider extends ChangeNotifier {
  int coins = 0;
  Timer? _saveTimer;
  Timer? _cropTimer;
  List<Plot> plots = [];
  final box = Hive.box('gameBox');

  List<Seed> seeds = [
    Seed(
      id: 'rice',
      name: 'Lúa nước',
      buyPrice: 30,
      sellPrice: 60,
      duration: Duration(seconds: 30),
      imagePath: 'rice',
    ),
    Seed(
      id: 'corn',
      name: 'Bắp ngô',
      buyPrice: 50,
      sellPrice: 100,
      duration: Duration(seconds: 60),
      imagePath: 'corn',
    ),
    Seed(
      id: 'tomato',
      name: 'Cà chua',
      buyPrice: 80,
      sellPrice: 160,
      duration: Duration(seconds: 80),
      imagePath: 'tomato',
    ),
    Seed(
      id: 'strawberry',
      name: 'Dâu tây',
      buyPrice: 100,
      sellPrice: 220,
      duration: Duration(seconds: 180),
      imagePath: 'strawberry',
    ),
    Seed(
      id: 'chilli',
      name: 'Ớt chuông',
      buyPrice: 60,
      sellPrice: 120,
      duration: Duration(seconds: 100),
      imagePath: 'chilli',
    ),
    Seed(
      id: 'eggplant',
      name: 'Cà tím',
      buyPrice: 70,
      sellPrice: 100,
      duration: Duration(seconds: 80),
      imagePath: 'eggplant',
    ),
  ];

  // quan trọng
  @override
  void dispose() {
    _saveTimer?.cancel();
    _cropTimer?.cancel();
    super.dispose();
  }

  GameProvider() {
    loadGame();
    // check mỗi giây
    _cropTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      checkCrops();
    });
  }

  void saveGame() {
    box.put('coins', coins);
    box.put('plots', plots.map((e) => e.toJson()).toList());
  }

  void scheduleAutoSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(seconds: 2), () {
      saveGame();
    });
  }

  void loadGame() {
    coins = box.get('coins', defaultValue: 3000);
    final data = box.get('plots');
    plots.clear();
    if (data == null || (data as List).isEmpty) {
      for (int i = 0; i < 60; i++) {
        plots.add(
          Plot(
            id: i,
            isUnlocked: i < 6, // 6 ô đầu mở
          ),
        );
      }
      box.put('plots', plots.map((e) => e.toJson()).toList());
    } else {
      plots.addAll(
        (data).map((e) => Plot.fromJson(Map<String, dynamic>.from(e))).toList(),
      );
    }

    notifyListeners();
  }

  void addCoins(int value) {
    coins += value;
    notifyListeners();
    saveGame();
  }

  bool spendCoins(int value) {
    if (coins < value) return false;
    coins -= value;
    notifyListeners();
    saveGame();
    return true;
  }

  bool unlockPlot(int index) {
    final plot = plots[index];
    if (plot.isUnlocked) {
      Sounds.failure();
      return false;
    }
    final price = getUnlockPrice(index);
    if (coins < price) {
      Sounds.failure();
      return false;
    }
    coins -= price;
    plot.isUnlocked = true;
    Sounds.congratulations();
    notifyListeners();
    saveGame();
    return true;
  }

  void checkCrops() {
    bool changed = false;
    for (final plot in plots) {
      if (plot.cropId == null || plot.plantTime == null) continue;
      final duration = getDurationSeconds(plot.cropId);
      final readyTime = plot.plantTime!.add(Duration(seconds: duration));
      if (DateTime.now().isAfter(readyTime) && !plot.isReady) {
        plot.isReady = true;
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
      saveGame();
    }
  }

  void harvest(int index) {
    final plot = plots[index];
    if (plot.cropId == null || !plot.isReady) return;
    int profit = getProfit(plot.cropId!);
    coins += profit;
    plot.cropId = null;
    plot.plantTime = null;
    plot.isReady = false;
    Sounds.coinin();
    notifyListeners();
    saveGame();
  }

  void plantCrop(int plotIndex, String cropId, int cost) async {
    final plot = plots[plotIndex];
    // ❌ check điều kiện
    if (!plot.isUnlocked) return;
    if (plot.cropId != null) return; // đã trồng rồi
    if (coins < cost) return;
    // 💰 trừ tiền
    Sounds.coinout();
    coins -= cost;
    await Future.delayed(Durations.long1);
    // 🌱 set crop
    plot.cropId = cropId;
    plot.plantTime = DateTime.now();
    plot.isReady = false;
    Sounds.seed();
    notifyListeners();
    saveGame();
  }

  int getUnlockPrice(int index) {
    return 200 * (index + 1);
  }

  int getProfit(String cropId) {
    return seeds.firstWhere((s) => s.id == cropId).sellPrice;
  }

  int getDurationSeconds(String? cropId) {
    return seeds.firstWhere((s) => s.id == cropId).duration.inSeconds;
  }

  String getImagepath(String? cropId) {
    return seeds.firstWhere((s) => s.id == cropId).imagePath;
  }
}
