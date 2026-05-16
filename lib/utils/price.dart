int getUnlockPrice(int plotIndex) {
  // plotIndex bắt đầu từ 0.
  // Ô thứ 7 là index 6, ô thứ 8 là index 7.
  if (plotIndex < 6) return 0; // 6 ô đầu free
  if (plotIndex == 6) return 4200; // Giá ô thứ 7 cố định là 4200

  // Tính giá dựa trên ô trước đó
  int previousPrice = getUnlockPrice(plotIndex - 1);

  // Tăng 20%
  double newPriceRaw = previousPrice * 1.2;

  // Làm tròn lên hàng trăm: (giá / 100).ceil() * 100
  int finalPrice = (newPriceRaw / 100).ceil() * 100;

  return finalPrice;
}

/* 
Ví dụ kết quả:
- Ô 7: 4200
- Ô 8: 4200 * 1.2 = 5040 -> Làm tròn lên: 5100
- Ô 9: 5100 * 1.2 = 6120 -> Làm tròn lên: 6200
*/
