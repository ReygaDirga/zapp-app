class UsageItem {
  final String itemId;
  final String roomId;
  final String name;
  final List<String> usageDays;
  final String startTime;
  final String endTime;
  final int usageWatt;
  final double totalCost;

  UsageItem({
    required this.itemId,
    required this.roomId,
    required this.name,
    required this.usageDays,
    required this.startTime,
    required this.endTime,
    required this.usageWatt,
    required this.totalCost,
  });

  factory UsageItem.fromJson(Map<String, dynamic> json) {
    return UsageItem(
      itemId: json['itemId'] ?? '',
      roomId: json['roomId'] ?? '',
      name: json['name'] ?? '',
      usageDays: List<String>.from(json['usageDays'] ?? []),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      usageWatt: json['usageWatt'] ?? 0,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0,
    );
  }
}