class ReviewModel {
  final String id;
  final String productId;
  final String userName;
  final String userAvatar;
  final int rating;
  final String title;
  final String comment;
  final bool isVerifiedPurchase;
  final DateTime? createdAt;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userName,
    this.userAvatar = '',
    required this.rating,
    required this.title,
    required this.comment,
    this.isVerifiedPurchase = false,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    String uName = 'Verified Collector';
    String uAvatar = '';

    if (json['user'] is Map) {
      uName = json['user']['name'] ?? 'Verified Collector';
      if (json['user']['avatar'] is Map) {
        uAvatar = json['user']['avatar']['url'] ?? '';
      }
    }

    return ReviewModel(
      id: json['_id'] ?? json['id'] ?? '',
      productId: json['product'] is Map ? (json['product']['_id'] ?? '') : (json['product'] ?? ''),
      userName: uName,
      userAvatar: uAvatar,
      rating: json['rating'] ?? 5,
      title: json['title'] ?? '',
      comment: json['comment'] ?? '',
      isVerifiedPurchase: json['isVerifiedPurchase'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
