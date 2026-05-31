import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Plot extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  bool isUnlocked;

  @HiveField(2)
  String? cropId;

  @HiveField(3)
  DateTime? plantTime;

  @HiveField(4)
  bool isReady;

  @HiveField(5)
  double progress;
  @HiveField(6)
  String progressImg;

  Plot({
    required this.id,
    this.isUnlocked = false,
    this.cropId,
    this.plantTime,
    this.isReady = false,
    this.progress = 0,
    this.progressImg = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isUnlocked': isUnlocked,
      'cropId': cropId,
      'plantTime': plantTime?.toIso8601String(),
    };
  }

  factory Plot.fromJson(Map<String, dynamic> json) {
    return Plot(
      id: json['id'],
      isUnlocked: json['isUnlocked'],
      cropId: json['cropId'],
      plantTime: json['plantTime'] == null
          ? null
          : DateTime.parse(json['plantTime']),
    );
  }
}
