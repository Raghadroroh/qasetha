class Product {
  final String id;
  final String title;
  final String titleEn;
  final String description;
  final String descriptionEn;
  final String imageUrl;
  final double price;
  final String categoryId;
  final List<InstallmentOption> installmentOptions;
  final bool isActive;
  final bool isFeatured;
  final int stockQuantity;
  final String? brand;
  final String? brandEn;
  final Map<String, dynamic>? specifications;
  final List<String> tags;
  final List<String> tagsEn;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double rating;
  final int reviewsCount;
  final int sortOrder;

  const Product({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.description,
    required this.descriptionEn,
    required this.imageUrl,
    required this.price,
    required this.categoryId,
    this.installmentOptions = const [],
    this.isActive = true,
    this.isFeatured = false,
    this.stockQuantity = 0,
    this.brand,
    this.brandEn,
    this.specifications,
    this.tags = const [],
    this.tagsEn = const [],
    required this.createdAt,
    required this.updatedAt,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.sortOrder = 0,
  });

  bool get isInStock => stockQuantity > 0;
  bool get isOnSale => installmentOptions.isNotEmpty;

  String getLocalizedTitle(String locale) {
    return locale == 'ar' ? title : titleEn;
  }

  String getLocalizedDescription(String locale) {
    return locale == 'ar' ? description : descriptionEn;
  }

  String? getLocalizedBrand(String locale) {
    if (locale == 'ar') return brand;
    return brandEn;
  }

  List<String> getLocalizedTags(String locale) {
    return locale == 'ar' ? tags : tagsEn;
  }

  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      title: data['title'] ?? '',
      titleEn: data['title_en'] ?? '',
      description: data['description'] ?? '',
      descriptionEn: data['description_en'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      categoryId: data['categoryId'] ?? '',
      installmentOptions: (data['installmentOptions'] as List<dynamic>?)
          ?.map((e) => InstallmentOption.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      isActive: data['isActive'] ?? true,
      isFeatured: data['isFeatured'] ?? false,
      stockQuantity: data['stockQuantity'] ?? 0,
      brand: data['brand'],
      brandEn: data['brand_en'],
      specifications: data['specifications'] as Map<String, dynamic>?,
      tags: List<String>.from(data['tags'] ?? []),
      tagsEn: List<String>.from(data['tags_en'] ?? []),
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as dynamic)?.toDate() ?? DateTime.now(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewsCount: data['reviewsCount'] ?? 0,
      sortOrder: data['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'title_en': titleEn,
      'description': description,
      'description_en': descriptionEn,
      'imageUrl': imageUrl,
      'price': price,
      'categoryId': categoryId,
      'installmentOptions': installmentOptions.map((e) => e.toMap()).toList(),
      'isActive': isActive,
      'isFeatured': isFeatured,
      'stockQuantity': stockQuantity,
      'brand': brand,
      'brand_en': brandEn,
      'specifications': specifications,
      'tags': tags,
      'tags_en': tagsEn,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'sortOrder': sortOrder,
    };
  }

  Product copyWith({
    String? id,
    String? title,
    String? titleEn,
    String? description,
    String? descriptionEn,
    String? imageUrl,
    double? price,
    String? categoryId,
    List<InstallmentOption>? installmentOptions,
    bool? isActive,
    bool? isFeatured,
    int? stockQuantity,
    String? brand,
    String? brandEn,
    Map<String, dynamic>? specifications,
    List<String>? tags,
    List<String>? tagsEn,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? rating,
    int? reviewsCount,
    int? sortOrder,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      titleEn: titleEn ?? this.titleEn,
      description: description ?? this.description,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      installmentOptions: installmentOptions ?? this.installmentOptions,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      brand: brand ?? this.brand,
      brandEn: brandEn ?? this.brandEn,
      specifications: specifications ?? this.specifications,
      tags: tags ?? this.tags,
      tagsEn: tagsEn ?? this.tagsEn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Product(id: $id, title: $title, titleEn: $titleEn, price: $price, categoryId: $categoryId)';
  }
}

class InstallmentOption {
  final int months;
  final double monthlyAmount;
  final double totalAmount;
  final double interestRate;
  final String description;
  final String descriptionEn;
  final bool isAvailable;

  const InstallmentOption({
    required this.months,
    required this.monthlyAmount,
    required this.totalAmount,
    required this.interestRate,
    required this.description,
    required this.descriptionEn,
    this.isAvailable = true,
  });

  String getLocalizedDescription(String locale) {
    return locale == 'ar' ? description : descriptionEn;
  }

  factory InstallmentOption.fromMap(Map<String, dynamic> data) {
    return InstallmentOption(
      months: data['months'] ?? 0,
      monthlyAmount: (data['monthlyAmount'] ?? 0.0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      interestRate: (data['interestRate'] ?? 0.0).toDouble(),
      description: data['description'] ?? '',
      descriptionEn: data['description_en'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'months': months,
      'monthlyAmount': monthlyAmount,
      'totalAmount': totalAmount,
      'interestRate': interestRate,
      'description': description,
      'description_en': descriptionEn,
      'isAvailable': isAvailable,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InstallmentOption &&
        other.months == months &&
        other.monthlyAmount == monthlyAmount;
  }

  @override
  int get hashCode => months.hashCode ^ monthlyAmount.hashCode;

  @override
  String toString() {
    return 'InstallmentOption(months: $months, monthlyAmount: $monthlyAmount)';
  }
}