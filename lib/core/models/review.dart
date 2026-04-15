class Review {
  const Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.processingTime,
    required this.userId,
    required this.status,
    required this.cafeId,
  });

  final int id;
  final String rating;
  final String comment;
  final String processingTime;
  final String userId;
  final String status;
  final int cafeId;

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: _parseInt(map['id']),
      rating: (map['rating'] ?? '-').toString(),
      comment: (map['comment'] ?? 'No review text').toString(),
      processingTime: (map['processing_time'] ?? 'Not provided').toString(),
      userId: (map['user_id'] ?? 'Anonymous').toString(),
      status: (map['status'] ?? 'Unknown').toString(),
      cafeId: _parseInt(map['cafe_id']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
