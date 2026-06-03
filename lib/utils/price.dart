int getUnlockPrice(int plotIndex) {
  if (plotIndex < 4) return 0; // 4 ô đầu free
  if (plotIndex == 4) return 6800; // Giá ô thứ 7 cố định là 6800
  int previousPrice = getUnlockPrice(plotIndex - 1);
  double newPriceRaw = previousPrice * 2.5;
  int finalPrice = (newPriceRaw / 100).ceil() * 100;
  return finalPrice;
}
