// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  @override
  void initState() {
    super.initState();
    Sounds.playBackground();
  }

  @override
  void dispose() {
    Sounds.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final game = context.read<GameProvider>();
    game.scheduleAutoSave();
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final padding = MediaQuery.of(context).padding;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/image/home.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.none,
          ),
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(20, 11, 18, 11),
                      Color.fromARGB(20, 90, 93, 91),
                      Color.fromARGB(20, 11, 18, 11),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          GridView.builder(
            padding: EdgeInsets.only(
              top: kToolbarHeight + padding.top + 22,
              left: 12,
              right: 12,
              bottom: kToolbarHeight + 20,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 ô mỗi hàng
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.9,
            ),
            itemCount: game.plots.length,
            itemBuilder: (context, index) {
              final plot = game.plots[index];
              return PlotWidget(plot: plot, index: index);
            },
          ),
          Positioned(
            top: padding.top,
            left: 0,
            right: 0,
            child: Container(
              alignment: AlignmentGeometry.center,
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/image/btn.png'),
                        fit: BoxFit.fitHeight,
                        filterQuality: FilterQuality.none,
                        colorFilter: ColorFilter.srgbToLinearGamma(),
                      ),
                    ),
                    height: kToolbarHeight * 1.2,
                    width: kToolbarHeight * 4,
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: kToolbarHeight * .1,
                        left: kToolbarHeight * .6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8,
                        children: [
                          Icon(MyIcon.coins01, color: Colors.white),
                          Text(
                            '${NumberFormat('#,###', 'vi_VN').format(game.coins).replaceAll(',', '.')} xu',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/image/icon.png'),
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.none,
                          colorFilter: ColorFilter.srgbToLinearGamma(),
                        ),
                      ),
                      padding: EdgeInsets.all(18),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4, left: 2),
                        child: Icon(
                          MyIcon.addcircle,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      Sounds.click();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ShopScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
