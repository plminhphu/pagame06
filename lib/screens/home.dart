// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pagame06/models/crop_model.dart';
import 'package:pagame06/screens/shop.dart';
import 'package:pagame06/utils/sounds.dart';
import 'package:pagame06/widget/icon.dart';
import 'package:pagame06/widget/plot.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _crossAxisCount = 4;
  Timer? rewardTimer;
  double rewardProgress = 0;
  bool canClaimReward = false;
  int rewardCoins = 0;

  @override
  void initState() {
    super.initState();
    Sounds.playBackground();
    startRewardTimer();
  }

  @override
  void dispose() {
    rewardTimer?.cancel();
    Sounds.dispose();
    super.dispose();
  }

  void startRewardTimer() {
    rewardTimer?.cancel();
    rewardProgress = 0;
    canClaimReward = false;
    const totalSeconds = 120;
    rewardTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        rewardProgress += 0.1 / totalSeconds;
        if (rewardProgress >= 1) {
          rewardProgress = 1;
          rewardCoins = (Random().nextInt(77) + 23) * 10;
          canClaimReward = true;
          timer.cancel();
        }
      });
    });
  }

  void claimReward() {
    if (!canClaimReward) return;
    final game = context.read<GameProvider>();
    Sounds.congratulations();
    game.addCoins(rewardCoins);
    Sounds.coinin();
    setState(() {
      rewardProgress = 0;
      canClaimReward = false;
    });
    startRewardTimer();
  }

  Offset _getPlotOffset(
    int index,
    double screenWidth,
    double topPadding,
    double availableHeight,
    int totalPlots,
  ) {
    final gridWidth = screenWidth - 40;
    final tileWidth = gridWidth / _crossAxisCount;
    final tileHeight = tileWidth / 1.2;
    final row = index ~/ _crossAxisCount;
    final col = index % _crossAxisCount;
    final totalRows = (totalPlots / _crossAxisCount).ceil();
    final gridHeight = totalRows * tileHeight;
    final startY = topPadding + (availableHeight - gridHeight);
    final tileX = 20 + col * tileWidth;
    final tileY = startY + row * tileHeight;
    final footX = tileX + tileWidth * .8;
    final footY = tileY + tileHeight * .9;
    return Offset(footX, footY);
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final padding = MediaQuery.of(context).padding;
    final screenWidth = MediaQuery.of(context).size.width;
    // Khoảng cách Padding Top của GridView cũ của bạn
    final double gridTopPadding = kToolbarHeight + padding.top + 22;
    // Lấy tọa độ hiện tại của nhân vật dựa vào Index đang đứng trong Provider
    final charOffset = _getPlotOffset(
      game.currentPlotIndex,
      screenWidth,
      gridTopPadding,
      MediaQuery.of(context).size.height - gridTopPadding - kToolbarHeight,
      game.plots.length,
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Giữ nguyên Hình nền cũ
          GestureDetector(
            onTap: () {
              Sounds.click();
              game.showSeedPicker = false;
            },
            child: Image.asset(
              'assets/image/home.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
            ),
          ),
          Positioned(
            top: gridTopPadding,
            left: 20,
            right: 20,
            bottom: kToolbarHeight,
            child: Container(
              alignment: Alignment.bottomCenter,
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _crossAxisCount,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: 1.2,
                ),
                itemCount: game.plots.length,
                itemBuilder: (context, index) {
                  final plot = game.plots[index];
                  return PlotWidget(plot: plot, index: index);
                },
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Duration(
              milliseconds: game.isWalking ? game.currentMoveDuration : 0,
            ),
            curve: Curves.easeOutQuad,
            left: charOffset.dx - 25,
            top: charOffset.dy - 40,
            child: GestureDetector(
              onTap: () {
                game.moveTo(game.currentPlotIndex);
              },
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (game.isWalking)
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: Image.asset(
                        'assets/image/character_walking.gif',
                        height: 50,
                        width: 50,
                      ),
                    ),
                  if (!game.isWalking)
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: Image.asset(
                        'assets/image/character_hi.gif',
                        height: 50,
                        width: 50,
                      ),
                    ),
                  Positioned(
                    top: -5,
                    child: Stack(
                      alignment: Alignment.center,
                      children: game.moneyEffects.map((effect) {
                        return _FloatingText(
                          key: effect.key,
                          text: effect.text,
                          color: effect.color,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: padding.top,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// COIN BAR
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade700,
                        Colors.blue.shade600,
                        Colors.blue.shade700,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.blue.shade900, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: Icon(
                          MyIcon.coins01,
                          color: Colors.blue.shade50,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${NumberFormat('#,###', 'vi_VN').format(game.coins).replaceAll(',', '.')} xu',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.blue.shade50,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 12,
                    children: [
                      GestureDetector(
                        onTap: claimReward,
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 45,
                                height: 45,
                                child: CircularProgressIndicator(
                                  value: rewardProgress,
                                  strokeWidth: 6,
                                  backgroundColor: Colors.white24,
                                  valueColor: AlwaysStoppedAnimation(
                                    canClaimReward
                                        ? Colors.lightGreen.shade700
                                        : Colors.lightBlue.shade700,
                                  ),
                                ),
                              ),
                              AnimatedScale(
                                scale: canClaimReward ? 1 : .9,
                                duration: const Duration(milliseconds: 250),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: canClaimReward
                                          ? [
                                              Colors.lightBlue.shade400,
                                              Colors.lightBlue.shade800,
                                            ]
                                          : [
                                              Colors.grey.shade700,
                                              Colors.grey.shade500,
                                            ],
                                    ),
                                  ),
                                  child: Icon(
                                    MyIcon.activity01,
                                    color: Colors.amber.shade100,
                                    size: 22,
                                  ),
                                ),
                              ),

                              /// số xu
                              if (canClaimReward)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '+$rewardCoins xu',
                                      style: TextStyle(
                                        color: Colors.green.shade600,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      /// SHOP BUTTON
                      GestureDetector(
                        onTap: () {
                          Sounds.click();
                          showGeneralDialog(
                            context: context,
                            barrierDismissible: true,
                            barrierLabel: 'shop',
                            barrierColor: Colors.black54,
                            transitionDuration: const Duration(
                              milliseconds: 250,
                            ),

                            pageBuilder: (_, _, _) {
                              return Center(
                                child: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    width: 380,
                                    constraints: const BoxConstraints(
                                      maxHeight: 620,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(
                                        color: Colors.blue.shade800,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 18,
                                          offset: const Offset(0, 8),
                                          color: Colors.black87,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(22),
                                      child: const ShopScreen(),
                                    ),
                                  ),
                                ),
                              );
                            },

                            transitionBuilder: (_, animation, _, child) {
                              return Transform.scale(
                                scale: Curves.easeOutBack.transform(
                                  animation.value,
                                ),
                                child: Opacity(
                                  opacity: animation.value,
                                  child: child,
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.blueAccent.shade400,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: Colors.blue.shade600,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade200,
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            MyIcon.shoppingbagadd,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AnimatedPositioned(
            duration: Durations.medium2,
            bottom: padding.bottom + 10,
            left: 0,
            right: 0,
            height: game.showSeedPicker ? 380 : 0,
            child: game.showSeedPicker
                ? GridView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.all(18),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.1,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: game.seeds.length,
                    itemBuilder: (context, index) {
                      return _seedOption(context, index);
                    },
                  )
                : SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _seedOption(BuildContext context, int index) {
    final game = Provider.of<GameProvider>(context, listen: false);
    Seed seed = game.seeds[index];

    return GestureDetector(
      onTap: () {
        Sounds.click();
        if (game.coins >= seed.buyPrice) {
          game.plantCrop(game.currentPlotIndex, seed.id, seed.buyPrice);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Bạn không đủ xu!')));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade400,
              Colors.blue.shade200,
              Colors.blue.shade400,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white70, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurStyle: BlurStyle.outer,
              blurRadius: 8,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              top: 12,
              left: 6,
              right: 6,
              child: Image.asset(
                'assets/image/${seed.id}.png',
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
              ),
            ),
            Positioned.fill(
              top: 4,
              left: 6,
              right: 6,
              bottom: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '-${seed.buyPrice}xu',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        Text(
                          '${seed.duration.inSeconds}s',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        Text(
                          '+${seed.sellPrice}xu',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    seed.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
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

// Widget xử lý hiệu ứng chữ tiền tự bay lên trên đầu nhân vật
class _FloatingText extends StatefulWidget {
  final String text;
  final Color color;
  const _FloatingText({required this.text, required this.color, super.key});

  @override
  State<_FloatingText> createState() => _FloatingTextState();
}

class _FloatingTextState extends State<_FloatingText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _translateY;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 55),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    _translateY = Tween<double>(
      begin: 0.0,
      end: -35.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _translateY.value),
          child: Opacity(
            opacity: _opacity.value,
            child: Stack(
              children: [
                Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 3
                      ..color = Colors.white, // Viền chữ màu đen cho nổi bật
                  ),
                ),
                Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
