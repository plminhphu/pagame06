import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pagame06/models/crop_model.dart';
import 'package:pagame06/models/plot_model.dart';
import 'package:pagame06/providers/game_provider.dart';
import 'package:pagame06/utils/price.dart';
import 'package:pagame06/utils/sounds.dart';
import 'package:pagame06/widget/icon.dart';
import 'package:provider/provider.dart';

class PlotWidget extends StatelessWidget {
  final Plot plot;
  final int index;

  const PlotWidget({super.key, required this.plot, required this.index});
  Stream<int> get timerStream =>
      Stream.periodic(const Duration(milliseconds: 500), (x) => x);

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        if (!plot.isUnlocked) {
          Sounds.click();
          _showUnlockDialog(context, game);
        } else {
          if (plot.isReady) {
            game.harvest(index);
          } else {
            if (plot.cropId == null) {
              Sounds.click();
              _showSeedPicker(context, index, game);
            } else {
              Sounds.inpross();
            }
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: !plot.isUnlocked
              ? Colors.brown.shade900.withAlpha(100)
              : plot.isReady
              ? Colors.amber.shade800.withAlpha(200)
              : Colors.green.shade600.withAlpha(200),
          borderRadius: BorderRadius.circular(6),
          border: plot.isReady
              ? Border.all(color: Colors.amber.shade800, width: 2)
              : null,
        ),
        child: Center(
          child: plot.isUnlocked
              ? plot.cropId == null
                    ? Icon(MyIcon.balloons, color: Colors.white70, size: 32)
                    : StreamBuilder(
                        stream: timerStream,
                        builder: (context, snapshot) {
                          String id = game.getImagepath(plot.cropId);
                          final now = DateTime.now();
                          final duration = game.getDurationSeconds(plot.cropId);
                          final plantedTime = plot.plantTime!;
                          final elapsed = now.difference(plantedTime).inSeconds;
                          final progress = elapsed / duration;
                          Widget child = Image.asset(
                            'assets/image/${id}_0.png',
                          );
                          // 1. mới trồng
                          if (progress >= .3 && progress < .6) {
                            child = Image.asset('assets/image/${id}_1.png');
                          }
                          // 2. đang lớn
                          if (progress >= .6 && progress < .9) {
                            child = Image.asset('assets/image/${id}_2.png');
                          }
                          // 3. chín
                          if (progress >= .9) {
                            child = Image.asset('assets/image/${id}_3.png');
                          }

                          return Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(2),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.green,
                                ),
                              ),
                              TweenAnimationBuilder(
                                tween: Tween<double>(begin: 0.8, end: 1.0),
                                duration: Durations.long2,
                                curve: Curves.easeInOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: child,
                                  );
                                },
                                child: child,
                              ),
                            ],
                          );
                        },
                      )
              : Icon(
                  MyIcon.locksync01,
                  color: Colors.brown.shade900.withAlpha(150),
                  size: 32,
                ),
        ),
      ).animate(target: 1).fade().scale(),
    );
  }

  void _showUnlockDialog(BuildContext context, GameProvider game) {
    int price = getUnlockPrice(index);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.green.shade50,
        title: Text('Mở rộng ô đất'),
        content: Text(
          'Bạn có muốn dùng $price xu để mở ô đất thứ ${index + 1}?',
        ),
        actions: [
          TextButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.green.shade100),
            ),
            onPressed: () {
              Sounds.click();
              Navigator.pop(context);
            },
            child: Text(
              'Để sau',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.green.shade800),
            ),
            onPressed: () {
              bool res = game.unlockPlot(index);
              if (res) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Chúc mừng bạn đã mở ô đất thứ ${index + 1}'),
                    backgroundColor: Colors.green.shade600,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Bạn không đủ xu để mở ô đất thứ ${index + 1}',
                    ),
                    backgroundColor: Colors.red.shade600,
                  ),
                );
              }
              Navigator.pop(context);
            },
            child: Text(
              'Mở khóa',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSeedPicker(BuildContext context, int plotIndex, GameProvider game) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CHỌN HẠT GIỐNG',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.brown[900],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: .65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 18,
                ),
                itemCount: game.seeds.length,
                itemBuilder: (context, index) {
                  Seed seed = game.seeds[index];
                  return _seedOption(context, plotIndex, seed);
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _seedOption(BuildContext context, int plotIndex, Seed seed) {
    final game = Provider.of<GameProvider>(context, listen: false);
    return GestureDetector(
      onTap: () {
        Sounds.click();
        if (game.coins >= seed.buyPrice) {
          game.plantCrop(plotIndex, seed.id, seed.buyPrice);

          Navigator.pop(context);
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Bạn không đủ xu!')));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade800,
              Colors.green.shade500,
              Colors.green.shade800,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.green.shade800.withAlpha(100),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(height: 4),
            SizedBox(
              width: 80,
              height: 80,
              child: Image.asset(
                'assets/image/${seed.id}_3.png',
              ), // Thay bằng Image.asset sau
            ),
            Text(
              seed.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Mua: ${seed.buyPrice} xu',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              'Chờ: ${seed.duration.inSeconds} giây',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              'Bán: ${seed.sellPrice} xu',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
