// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pagame06/providers/game_provider.dart';
import 'package:pagame06/utils/sounds.dart';
import 'package:pagame06/widget/icon.dart';
import 'package:provider/provider.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<ProductDetails> storeProducts = [];
  late StreamSubscription<List<PurchaseDetails>> _sub;
  String idPurchaseHandled = '';

  @override
  void initState() {
    super.initState();
    loadProducts();
    _sub = InAppPurchase.instance.purchaseStream.listen(_listenPurchaseUpdated);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  Future<void> _listenPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        Sounds.congratulations();
        await _deliverProduct(purchase);
      }
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchase) async {
    final purchaseId = purchase.purchaseID ?? '';
    final handled = idPurchaseHandled == purchaseId;
    if (handled) return;
    ProductDetails? storeProduct = storeProducts.firstWhere(
      (sP) => sP.id == purchase.productID,
    );
    int nodes =
        int.tryParse(
          storeProduct.title
              .replaceAll('(Đảo Khủng Long)', '')
              .replaceAll('Nạp', '')
              .replaceAll('Xu', '')
              .trim(),
        ) ??
        0;
    Provider.of<GameProvider>(context).addCoins(nodes);
    Sounds.coinin();
    idPurchaseHandled = purchaseId;
    if (mounted) {
      setState(() {});
    }
  }

  Future loadProducts() async {
    final response = await InAppPurchase.instance.queryProductDetails({
      'coin_1',
      'coin_2',
      'coin_3',
      'coin_4',
      'coin_5',
      'coin_6',
      'coin_7',
      'coin_8',
      'coin_9',
    });
    storeProducts = response.productDetails;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final game = Provider.of<GameProvider>(context);
    return (storeProducts.isEmpty)
        ? const Center(child: CupertinoActivityIndicator())
        : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: .6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 12,
            ),
            padding: const EdgeInsets.all(8),
            itemCount: storeProducts.length,
            itemBuilder: (context, index) {
              final storeProduct = storeProducts[index];
              String title = storeProduct.title
                  .replaceAll('(Đảo Khủng Long)', '')
                  .trim();
              return TweenAnimationBuilder(
                duration: Duration(milliseconds: 250 + (index * 120)),
                tween: Tween(begin: .8, end: 1.0),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(255, 79, 72, 45),
                        Color.fromARGB(255, 115, 96, 23),
                        Color.fromARGB(255, 79, 72, 45),
                      ],
                    ),
                    border: Border.all(color: Colors.green.shade200, width: 2),
                  ),
                  child: Stack(
                    children: [
                      /// glow background
                      Positioned.fill(
                        child: Opacity(
                          opacity: .08,
                          child: Icon(
                            MyIcon.coins01,
                            size: 120,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        margin: const EdgeInsets.only(top: 6),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.amber.shade100.withAlpha(50),
                                    border: Border.all(
                                      color: Colors.amber.shade300.withAlpha(
                                        30,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                  child: GestureDetector(
                                    onDoubleTap: () async {
                                      Navigator.pop(context);
                                      Sounds.congratulations();
                                      int nodes =
                                          int.tryParse(
                                            storeProduct.title
                                                .replaceAll(
                                                  '(Đảo Khủng Long)',
                                                  '',
                                                )
                                                .replaceAll('Nạp', '')
                                                .replaceAll('Xu', '')
                                                .trim(),
                                          ) ??
                                          0;
                                      game.addCoins(nodes);
                                      Sounds.coinin();
                                    },
                                    child: Icon(
                                      MyIcon.coins02,
                                      color: Colors.amber,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    height: 1.4,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 2),
                                  child: Text(
                                    storeProduct.description,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () async {
                                Sounds.click();
                                try {
                                  final purchaseParam = PurchaseParam(
                                    productDetails: storeProduct,
                                  );
                                  await InAppPurchase.instance.buyConsumable(
                                    purchaseParam: purchaseParam,
                                    autoConsume: true,
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red.shade700,
                                      content: Text('Không tìm thấy sản phẩm'),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 6),
                                margin: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.amber.shade400,
                                      Colors.orange.shade600,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange,
                                      blurRadius: 6,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      MyIcon.shoppingbagadd,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      storeProduct.price,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
