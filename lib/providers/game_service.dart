import 'package:hive/hive.dart';

class SaveService {
  static final box = Hive.box('game');

  static int getCoins() => box.get('coins', defaultValue: 1000);

  static void saveCoins(int coins) => box.put('coins', coins);

  static List getPlots() => box.get('plots', defaultValue: []);

  static void savePlots(List plots) => box.put('plots', plots);
}
