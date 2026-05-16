// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pagame06/utils/sounds.dart';
import 'package:pagame06/widget/icon.dart';

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
        Sounds.congratulations();
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
              .replaceAll('(Thần Nông)', '')
              .replaceAll('Nạp', '')
              .replaceAll('Xu', '')
              .trim(),
        ) ??
        0;
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
    final padding = MediaQuery.of(context).padding;
    return Scaffold(
      backgroundColor: colorScheme.shadow,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/image/shop.png',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.none,
          ),
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(120, 11, 18, 11),
                      Color.fromARGB(120, 90, 93, 91),
                      Color.fromARGB(120, 11, 18, 11),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          (storeProducts.isEmpty)
              ? const Center(child: CupertinoActivityIndicator())
              : GridView.builder(
                  padding: EdgeInsets.only(
                    top: kToolbarHeight + padding.top + 20,
                    left: 12,
                    right: 12,
                    bottom: kToolbarHeight + 12,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: .7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 18,
                  ),
                  itemCount: storeProducts.length,
                  itemBuilder: (context, index) {
                    ProductDetails storeProduct = storeProducts[index];
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade900,
                            Colors.green.shade800,
                            Colors.green.shade900,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade900.withAlpha(100),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Icon(
                                  MyIcon.addcirclehalfdot,
                                  color: Colors.green.shade100,
                                  size: 35,
                                ),
                                Text(
                                  storeProduct.title
                                      .replaceAll('(Thần Nông)', '')
                                      .trim(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  storeProducts[index].description,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
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
                                  const SnackBar(
                                    content: Text('Không tìm thấy sản phẩm'),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Text(
                                storeProducts[index].price,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          Positioned(
            top: padding.top,
            left: 0,
            right: 12,
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
                      bottom: kToolbarHeight * .15,
                    ),
                    child: Text(
                      'Nạp thêm xu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/image/icon.png'),
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.none,
                        colorFilter: ColorFilter.srgbToLinearGamma(),
                      ),
                    ),
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      MyIcon.arrowdown01,
                      color: Colors.white70,
                      size: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Sounds.click();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
