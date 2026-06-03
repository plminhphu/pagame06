import 'package:flutter/material.dart';
import 'package:pagame06/models/plot_model.dart';
import 'package:pagame06/providers/game_provider.dart';
import 'package:provider/provider.dart';

class PlotWidget extends StatelessWidget {
  final Plot plot;
  final int index;

  const PlotWidget({super.key, required this.plot, required this.index});
  Stream<int> get timerStream =>
      Stream.periodic(const Duration(seconds: 1), (x) => x);

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context, listen: false);
    double wPlot = MediaQuery.of(context).size.width / 5;
    double wMinPlot = wPlot * .6;
    double wMaxPlot = wPlot * 1.1;
    final now = DateTime.now();
    final nowS = plot.plantTime != null
        ? now.difference(plot.plantTime!).inSeconds
        : 0;
    // Xác định xem đang ở chu kỳ 5s chẵn hay lẻ (true/false)
    final isMovingRight =
        (nowS ~/ 5) % 2 != 0; // 1. Tính số giây đã trôi qua kể từ khi trồng

    // 2. Lấy tổng thời gian cây cần để chín (ví dụ lấy từ object game hoặc crop của bạn)
    final int totalSeconds = plot.plantTime != null
        ? game.getDurationSeconds(plot.cropId)
        : 0;
    // 3. Tính số giây còn lại (nếu đã chín thì trả về 0)
    final remainingSeconds = totalSeconds - nowS > 0 ? totalSeconds - nowS : 0;
    return GestureDetector(
      onTap: () async {
        await game.moveTo(index);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (!plot.isUnlocked)
            AnimatedPositioned(
              duration: Durations.medium4,
              curve: Curves.easeInOut,
              bottom: 0,
              left: 20,
              right: 20,
              child: Image.asset(
                'assets/image/plot_unlocked.png',
                filterQuality: FilterQuality.none,
              ),
            ),
          if (plot.isUnlocked && plot.cropId != null && plot.progress > 0.1)
            AnimatedPositioned(
              duration: const Duration(
                seconds: 5,
              ), // Đổi thành 5s để khớp với thời gian đi qua đi lại
              curve: Curves.linear,
              bottom: -2,
              left: isMovingRight ? 30 : 0,
              right: isMovingRight ? 0 : 30,
              height: (plot.progress * wPlot).clamp(wMinPlot, wMaxPlot),
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 300,
                ), // Thời gian lật (300ms là vừa đẹp)
                curve: Curves.easeInOut,
                alignment: Alignment.center,
                // Dùng ma trận để xoay trục Y mượt mà
                transform: Matrix4.rotationY(
                  isMovingRight ? 0 : 3.14159,
                ), // 3.14159 radian = 180 độ
                transformAlignment: Alignment.center,
                child: Image.asset(
                  'assets/image/${game.getImagepath(plot.cropId)}.png',
                  filterQuality: FilterQuality.none,
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
          if (plot.isUnlocked)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: wPlot,
              child: (plot.progress <= 0 || plot.progress > 0.1)
                  ? Image.asset(
                      'assets/image/plot_locked.png',
                      filterQuality: FilterQuality.none,
                      fit: BoxFit.fitHeight,
                      alignment: Alignment.bottomCenter,
                    )
                  : Image.asset(
                      'assets/image/plot_fcroped.png',
                      filterQuality: FilterQuality.none,
                      fit: BoxFit.fitHeight,
                      alignment: Alignment.bottomCenter,
                    ),
            ),
          if (plot.isUnlocked &&
              plot.cropId != null &&
              (plot.progress > 0 && plot.progress <= 0.1))
            AnimatedPositioned(
              duration: Durations.extralong4,
              curve: Curves.easeIn,
              top: 10,
              bottom: 0,
              left: 10,
              right: 10,
              child: Image.asset(
                'assets/image/plot_croped.png',
                filterQuality: FilterQuality.none,
                fit: BoxFit.fill,
                alignment: Alignment.bottomCenter,
              ),
            ),
          if (plot.cropId != null)
            Positioned(
              top: 12,
              left: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                ),
                child: LinearProgressIndicator(
                  value: plot.progress,
                  borderRadius: BorderRadius.circular(2),
                  minHeight: 2,
                  color: plot.isReady
                      ? Colors.green.shade400.withAlpha(200)
                      : Colors.amber.shade400.withAlpha(200),
                  backgroundColor: Colors.white60.withAlpha(100),
                ),
              ),
            ),
          if (plot.cropId != null)
            Positioned(
              top: 1.5,
              left: 4,
              right: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plot.cropId ?? '',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$remainingSeconds',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
