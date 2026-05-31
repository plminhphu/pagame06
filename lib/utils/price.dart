int getUnlockPrice(int plotIndex) {
  // Ô thứ 7 là index 6, ô thứ 8 là index 7.
  if (plotIndex < 6) return 0; // 6 ô đầu free
  if (plotIndex == 6) return 6800; // Giá ô thứ 7 cố định là 4200
  // Tính giá dựa trên ô trước đó
  int previousPrice = getUnlockPrice(plotIndex - 1);
  double newPriceRaw = previousPrice * 1.6;
  // Làm tròn lên hàng trăm: (giá / 100).ceil() * 100
  int finalPrice = (newPriceRaw / 100).ceil() * 100;
  return finalPrice;
}
