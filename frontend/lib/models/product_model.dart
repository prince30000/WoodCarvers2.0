import 'category_model.dart';

class ProductImage {
  final String url;
  final String publicId;
  final bool isPrimary;
  final String alt;

  ProductImage({
    required this.url,
    this.publicId = '',
    this.isPrimary = false,
    this.alt = '',
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      url: json['url'] ?? '',
      publicId: json['publicId'] ?? '',
      isPrimary: json['isPrimary'] ?? false,
      alt: json['alt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'publicId': publicId,
    'isPrimary': isPrimary,
    'alt': alt,
  };
}

class ProductModel {
  final String id;
  final String title;
  final String slug;
  final String sku;
  final String description;
  final dynamic category; // Can be CategoryModel or String ID
  final num price;
  final num discountPercent;
  final num discountedPrice;
  final int stock;
  final List<ProductImage> images;
  final Map<String, dynamic> dimensions;
  final Map<String, dynamic> weight;
  final String material;
  final String careInstructions;
  final String craftsmanshipInfo;
  final String shippingInfo;
  final String returnPolicy;
  final List<String> tags;
  final bool isFeatured;
  final bool isBestseller;
  final bool isNewArrival;
  final bool isActive;
  final double ratingsAverage;
  final int ratingsCount;

  ProductModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.sku,
    required this.description,
    this.category,
    required this.price,
    this.discountPercent = 0,
    required this.discountedPrice,
    required this.stock,
    this.images = const [],
    this.dimensions = const {},
    this.weight = const {},
    this.material = 'Natural Seasoned Wood',
    this.careInstructions = '',
    this.craftsmanshipInfo = '',
    this.shippingInfo = '',
    this.returnPolicy = '',
    this.tags = const [],
    this.isFeatured = false,
    this.isBestseller = false,
    this.isNewArrival = false,
    this.isActive = true,
    this.ratingsAverage = 4.8,
    this.ratingsCount = 0,
  });

  String get primaryImageUrl {
    if (images.isEmpty) {
      return 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?auto=format&fit=crop&w=800&q=80';
    }
    final primary = images.firstWhere((img) => img.isPrimary, orElse: () => images.first);
    return primary.url;
  }

  String get categoryName {
    if (category is CategoryModel) {
      return (category as CategoryModel).name;
    }
    if (category is Map && category['name'] != null) {
      return category['name'].toString();
    }
    return '';
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<ProductImage> imgList = [];
    if (json['images'] is List) {
      imgList = (json['images'] as List)
          .map((item) => ProductImage.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    dynamic cat;
    if (json['category'] is Map) {
      cat = CategoryModel.fromJson(json['category'] as Map<String, dynamic>);
    } else {
      cat = json['category'];
    }

    List<String> tagList = [];
    if (json['tags'] is List) {
      tagList = (json['tags'] as List).map((e) => e.toString()).toList();
    }

    final priceNum = json['price'] ?? 0;
    final discountNum = json['discountPercent'] ?? 0;
    final discountedPriceNum = json['discountedPrice'] ?? (discountNum > 0 ? (priceNum * (1 - discountNum / 100)).round() : priceNum);

    return ProductModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      sku: json['sku'] ?? '',
      description: json['description'] ?? '',
      category: cat,
      price: priceNum,
      discountPercent: discountNum,
      discountedPrice: discountedPriceNum,
      stock: json['stock'] ?? 0,
      images: imgList,
      dimensions: json['dimensions'] is Map ? Map<String, dynamic>.from(json['dimensions']) : {},
      weight: json['weight'] is Map ? Map<String, dynamic>.from(json['weight']) : {},
      material: json['material'] ?? 'Natural Seasoned Wood',
      careInstructions: json['careInstructions'] ?? '',
      craftsmanshipInfo: json['craftsmanshipInfo'] ?? '',
      shippingInfo: json['shippingInfo'] ?? '',
      returnPolicy: json['returnPolicy'] ?? '',
      tags: tagList,
      isFeatured: json['isFeatured'] ?? false,
      isBestseller: json['isBestseller'] ?? false,
      isNewArrival: json['isNewArrival'] ?? false,
      isActive: json['isActive'] ?? true,
      ratingsAverage: (json['ratingsAverage'] is num) ? (json['ratingsAverage'] as num).toDouble() : 4.8,
      ratingsCount: json['ratingsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'slug': slug,
    'sku': sku,
    'description': description,
    'category': category is CategoryModel ? (category as CategoryModel).id : category,
    'price': price,
    'discountPercent': discountPercent,
    'discountedPrice': discountedPrice,
    'stock': stock,
    'images': images.map((e) => e.toJson()).toList(),
    'dimensions': dimensions,
    'weight': weight,
    'material': material,
    'careInstructions': careInstructions,
    'craftsmanshipInfo': craftsmanshipInfo,
    'shippingInfo': shippingInfo,
    'returnPolicy': returnPolicy,
    'tags': tags,
    'isFeatured': isFeatured,
    'isBestseller': isBestseller,
    'isNewArrival': isNewArrival,
    'isActive': isActive,
  };
}
