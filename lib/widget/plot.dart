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
    return GestureDetector(
      onTap: () async {
        await game.moveTo(index);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            top: plot.isUnlocked
                ? -(plot.progress * 5)
                : (index % 2 == 0 ? 10 : 15).toDouble(),
            bottom: -20,
            left: plot.isUnlocked
                ? -(plot.progress * 15)
                : -(index % 2 == 0 ? 15 : 5).toDouble(),
            right: plot.isUnlocked
                ? -(plot.progress * 15)
                : -(index % 2 == 0 ? 0 : 20).toDouble(),
            child:
                plot.isUnlocked && plot.progress >= 0.1 && plot.cropId != null
                ? Image.asset(
                    'assets/image/${game.getImagepath(plot.cropId)}.png',
                    filterQuality: FilterQuality.none,
                  )
                : SizedBox(),
          ),
          Positioned(
            bottom: 0,
            left: plot.isUnlocked
                ? plot.progress < 0.1 && plot.cropId != null
                      ? 15
                      : -2
                : 10,
            right: plot.isUnlocked
                ? plot.progress < 0.1 && plot.cropId != null
                      ? 15
                      : -2
                : 10,
            child: plot.isUnlocked
                ? plot.cropId == null
                      ? Image.asset('assets/image/plot_locked.png')
                      : plot.progress < 0.1
                      ? Image.asset('assets/image/plot_croped.png')
                      : Image.asset('assets/image/plot_locked.png')
                : Image.asset('assets/image/plot_unlocked.png'),
          ),
          if (plot.cropId != null)
            Positioned(
              top: -(10 + plot.progress * 10),
              left: 15,
              right: 15,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: plot.isReady
                        ? Colors.green.shade800.withAlpha(220)
                        : Colors.amber.shade600.withAlpha(220),
                    width: .6,
                  ),
                ),
                child: LinearProgressIndicator(
                  value: plot.progress,
                  borderRadius: BorderRadius.circular(6),
                  color: plot.isReady
                      ? Colors.green.shade400.withAlpha(220)
                      : Colors.amber.shade400.withAlpha(220),
                  backgroundColor: Colors.white60.withAlpha(220),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
