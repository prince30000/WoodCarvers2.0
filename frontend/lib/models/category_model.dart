class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String imageUrl;
  final int displayOrder;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description = '',
    this.imageUrl = '',
    this.displayOrder = 0,
    this.isActive = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    String img = '';
    if (json['image'] is Map && json['image']['url'] != null) {
      img = json['image']['url'].toString();
    } else if (json['image'] is String) {
      img = json['image'];
    }

    return CategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      imageUrl: img,
      displayOrder: json['displayOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'description': description,
    'image': {'url': imageUrl},
    'displayOrder': displayOrder,
    'isActive': isActive,
  };
}
