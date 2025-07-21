class Category {
  final String id;
  final String name;
  final String nameEn;
  final String? description;
  final String? descriptionEn;
  final String? iconUrl;
  final String? parentId;
  final String type;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int sortOrder;

  const Category({
    required this.id,
    required this.name,
    required this.nameEn,
    this.description,
    this.descriptionEn,
    this.iconUrl,
    this.parentId,
    required this.type,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.sortOrder = 0,
  });

  bool get isMainCategory => parentId == null;
  bool get hasSubcategories => !isMainCategory;

  String getLocalizedName(String locale) {
    return locale == 'ar' ? name : nameEn;
  }

  String? getLocalizedDescription(String locale) {
    if (locale == 'ar') return description;
    return descriptionEn;
  }

  factory Category.fromFirestore(Map<String, dynamic> data, String id) {
    return Category(
      id: id,
      name: data['name'] ?? '',
      nameEn: data['name_en'] ?? '',
      description: data['description'],
      descriptionEn: data['description_en'],
      iconUrl: data['iconUrl'],
      parentId: data['parentId'],
      type: data['type'] ?? 'general',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as dynamic)?.toDate() ?? DateTime.now(),
      sortOrder: data['sortOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'name_en': nameEn,
      'description': description,
      'description_en': descriptionEn,
      'iconUrl': iconUrl,
      'parentId': parentId,
      'type': type,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'sortOrder': sortOrder,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? description,
    String? descriptionEn,
    String? iconUrl,
    String? parentId,
    String? type,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sortOrder,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      description: description ?? this.description,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      iconUrl: iconUrl ?? this.iconUrl,
      parentId: parentId ?? this.parentId,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Category(id: $id, name: $name, nameEn: $nameEn, type: $type, parentId: $parentId)';
  }
}