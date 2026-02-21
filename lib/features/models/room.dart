class Room {
  final String roomId;
  final String userId;
  final String name;
  final String imageUrl;

  Room ({
    required this.roomId,
    required this.userId,
    required this.name,
    required this.imageUrl,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomId: json['room_id'],
      userId: json['user_id'],
      name: json['name'],
      imageUrl: json['image_url'] ?? '',
    );
  }
}