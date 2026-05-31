import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pagame06/models/crop_model.dart';
import 'package:pagame06/providers/service.dart';
import 'package:pagame06/providers/toast.dart';
import 'package:pagame06/utils/sounds.dart';
import 'package:pagame06/widget/icon.dart';
import '../models/plot_model.dart';

class GameProvider extends ChangeNotifier {
  int coins = 0;
  Timer? _cropTimer;
  List<Plot> plots = [];
  int currentPlotIndex = 0;
  bool isWalking = false;
  bool showSeedPicker = false;
  int currentMoveDuration = 0;
  final List<FloatingMoney> moneyEffects = [];
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
    _cropTimer?.cancel();
    super.dispose();
  }

  GameProvider() {
    loadGame();
    _cropTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      checkCrops();
    });
  }

  void saveGame() {
    box.put('coins', coins);
    box.put('plots', plots.map((e) => e.toJson()).toList());
  }

  void loadGame() {
    coins = box.get('coins', defaultValue: 3200);
    final data = box.get('plots');
    plots.clear();
    if (data == null || (data as List).isEmpty) {
      for (int i = 0; i < 40; i++) {
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
    showMoneyEffect(value);
    saveGame();
  }

  bool spendCoins(int value) {
    if (coins < value) return false;
    coins -= value;
    notifyListeners();
    showMoneyEffect(-value);
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
    final now = DateTime.now();
    for (final plot in plots) {
      if (plot.cropId == null || plot.plantTime == null) continue;
      final duration = getDurationSeconds(plot.cropId);
      final readyTime = plot.plantTime!.add(Duration(seconds: duration));
      if (DateTime.now().isAfter(readyTime) && !plot.isReady) {
        plot.progress = 1;
        plot.progressImg = '3';
        plot.isReady = true;
        notifyListeners();
        changed = true;
      } else if (plot.plantTime != null && !plot.isReady) {
        plot.progress = now.difference(plot.plantTime!).inSeconds / duration;
        if (plot.progress < .25) {
          plot.progressImg = '';
        } else if (plot.progress >= .25 && plot.progress < .5) {
          plot.progressImg = '0';
        } else if (plot.progress >= .5 && plot.progress < .75) {
          plot.progressImg = '1';
        } else if (plot.progress >= .75 && plot.progress < .9) {
          plot.progressImg = '2';
        } else if (plot.progress >= .9) {
          plot.progressImg = '3';
        }
        notifyListeners();
      }
    }
    if (changed) {
      saveGame();
    }
  }

  // SỬA HÀM THU HOẠCH: Gọi qua controller mới
  void harvest(int index) async {
    final plot = plots[index];
    if (plot.cropId == null || !plot.isReady) return;
    int profit = getProfit(plot.cropId!);
    coins += profit;
    // 🔥 HIỆU ỨNG MỚI: Cộng tiền ngay trên đầu nhân vật
    triggerMoneyEffect(profit);
    // Vẫn giữ Toast cũ nếu bạn muốn hiện cả 2 nơi
    plot.cropId = null;
    plot.plantTime = null;
    plot.isReady = false;
    plot.progress = 0;
    plot.progressImg = '';
    Sounds.coinin();
    notifyListeners();
    saveGame();
  }

  // SỬA HÀM TRỒNG CÂY: Gọi qua controller mới
  void plantCrop(int plotIndex, String cropId, int cost) async {
    final plot = plots[plotIndex];
    if (!plot.isUnlocked || plot.cropId != null || coins < cost) return;
    Sounds.coinout();
    coins -= cost;
    // 🔥 HIỆU ỨNG MỚI: Trừ tiền ngay trên đầu nhân vật
    triggerMoneyEffect(-cost);
    await Future.delayed(Durations.medium2);
    plot.progress = 0;
    plot.progressImg = '';
    plot.cropId = cropId;
    plot.plantTime = DateTime.now();
    plot.isReady = false;
    Sounds.seed();
    showSeedPicker = false;
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

  void showMoneyEffect(int amount) {
    if (amount > 0) {
      Toast.success('+$amount');
    } else {
      Toast.error('$amount');
    }
  }

  Future<void> moveTo(int targetIndex) async {
    showSeedPicker = false;
    int crossAxisCount = 5;
    if (currentPlotIndex == targetIndex) return;
    int currentRow = currentPlotIndex ~/ crossAxisCount;
    int currentCol = currentPlotIndex % crossAxisCount;
    int targetRow = targetIndex ~/ crossAxisCount;
    int targetCol = targetIndex % crossAxisCount;
    double realDistance = sqrt(
      pow(targetRow - currentRow, 2) + pow(targetCol - currentCol, 2),
    );
    currentMoveDuration = (realDistance * 350).round().clamp(250, 2000);
    isWalking = true;
    currentPlotIndex = targetIndex;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: currentMoveDuration));
    isWalking = false;
    notifyListeners();
    Plot plot = plots[targetIndex];
    if (plot.isUnlocked) {
      if (plot.isReady) {
        harvest(targetIndex);
      } else {
        if (plot.cropId == null) {
          showSeedPicker = true;
          notifyListeners();
        } else {
          Sounds.inpross();
        }
      }
    } else {
      Sounds.click();
      showUnlockDialog(targetIndex);
    }
  }

  void triggerMoneyEffect(int amount) {
    final isPositive = amount > 0;
    final text = isPositive ? '+$amount xu' : '$amount xu';
    final color = isPositive ? Colors.amber.shade600 : Colors.red.shade600;
    final effect = FloatingMoney(text: text, color: color);
    moneyEffects.add(effect);
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 500), () {
      moneyEffects.remove(effect);
      notifyListeners();
    });
  }

  void showUnlockDialog(int index) {
    final context = AppService.navigatorKey.currentContext!;
    int price = getUnlockPrice(index);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'unlock',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, _, _) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF5FFE8),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.green.shade800, width: 4),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 28,
                    offset: const Offset(0, 18),
                    color: Colors.black87,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(MyIcon.tree01, size: 72, color: Colors.green.shade700),

                  const SizedBox(height: 12),

                  Text(
                    'MỞ RỘNG Ô ĐẤT',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'Dùng $price xu để mở ô đất thứ ${index + 1}?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: Colors.brown.shade700,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Sounds.click();
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.green.shade700,
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'ĐỂ SAU',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            bool res = unlockPlot(index);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  res
                                      ? 'Đã mở ô đất thứ ${index + 1}'
                                      : 'Không đủ xu',
                                ),
                                backgroundColor: res
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.green.shade700,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'MỞ KHÓA',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, animation, _, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(animation.value),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
    );
  }
}

class FloatingMoney {
  final String text;
  final Color color;
  final Key key = UniqueKey();

  FloatingMoney({required this.text, required this.color});
}
