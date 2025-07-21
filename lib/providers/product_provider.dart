import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/logger_service.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  Future<List<Product>> getAllProducts() async {
    try {
      LoggerService.info('Fetching all products from Firestore');
      
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .orderBy('title')
          .get();

      final products = querySnapshot.docs
          .map((doc) => Product.fromFirestore(doc.data(), doc.id))
          .toList();

      LoggerService.info('Successfully fetched ${products.length} products');
      return products;
    } catch (e) {
      LoggerService.error('Error fetching products: $e');
      throw Exception('Failed to fetch products: $e');
    }
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      LoggerService.info('Fetching products for category: $categoryId');
      
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('categoryId', isEqualTo: categoryId)
          .where('isActive', isEqualTo: true)
          .orderBy('isFeatured', descending: true)
          .orderBy('sortOrder')
          .orderBy('title')
          .get();

      final products = querySnapshot.docs
          .map((doc) => Product.fromFirestore(doc.data(), doc.id))
          .toList();

      LoggerService.info('Successfully fetched ${products.length} products for category');
      return products;
    } catch (e) {
      LoggerService.error('Error fetching products by category: $e');
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    try {
      LoggerService.info('Fetching featured products');
      
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isFeatured', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .orderBy('title')
          .limit(limit)
          .get();

      final products = querySnapshot.docs
          .map((doc) => Product.fromFirestore(doc.data(), doc.id))
          .toList();

      LoggerService.info('Successfully fetched ${products.length} featured products');
      return products;
    } catch (e) {
      LoggerService.error('Error fetching featured products: $e');
      throw Exception('Failed to fetch featured products: $e');
    }
  }

  Future<List<Product>> getRecentProducts({int limit = 10}) async {
    try {
      LoggerService.info('Fetching recent products');
      
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final products = querySnapshot.docs
          .map((doc) => Product.fromFirestore(doc.data(), doc.id))
          .toList();

      LoggerService.info('Successfully fetched ${products.length} recent products');
      return products;
    } catch (e) {
      LoggerService.error('Error fetching recent products: $e');
      throw Exception('Failed to fetch recent products: $e');
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      LoggerService.info('Fetching product by ID: $id');
      
      final doc = await _firestore.collection(_collection).doc(id).get();
      
      if (!doc.exists) {
        LoggerService.warning('Product not found: $id');
        return null;
      }

      final product = Product.fromFirestore(doc.data()!, doc.id);
      LoggerService.info('Successfully fetched product: ${product.title}');
      return product;
    } catch (e) {
      LoggerService.error('Error fetching product by ID: $e');
      throw Exception('Failed to fetch product: $e');
    }
  }

  Future<List<Product>> searchProducts(String query, {String? categoryId}) async {
    try {
      LoggerService.info('Searching products with query: $query');
      
      Query<Map<String, dynamic>> queryRef = _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true);
      
      if (categoryId != null && categoryId.isNotEmpty) {
        queryRef = queryRef.where('categoryId', isEqualTo: categoryId);
      }
      
      final querySnapshot = await queryRef.get();

      final products = querySnapshot.docs
          .map((doc) => Product.fromFirestore(doc.data(), doc.id))
          .where((product) {
            final lowerQuery = query.toLowerCase();
            return product.title.toLowerCase().contains(lowerQuery) ||
                   product.titleEn.toLowerCase().contains(lowerQuery) ||
                   product.description.toLowerCase().contains(lowerQuery) ||
                   product.descriptionEn.toLowerCase().contains(lowerQuery) ||
                   product.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)) ||
                   product.tagsEn.any((tag) => tag.toLowerCase().contains(lowerQuery));
          })
          .toList();

      products.sort((a, b) {
        final aRelevance = _calculateRelevance(a, query);
        final bRelevance = _calculateRelevance(b, query);
        return bRelevance.compareTo(aRelevance);
      });

      LoggerService.info('Successfully found ${products.length} products matching query');
      return products;
    } catch (e) {
      LoggerService.error('Error searching products: $e');
      throw Exception('Failed to search products: $e');
    }
  }

  int _calculateRelevance(Product product, String query) {
    int relevance = 0;
    final lowerQuery = query.toLowerCase();
    
    if (product.title.toLowerCase().contains(lowerQuery)) relevance += 3;
    if (product.titleEn.toLowerCase().contains(lowerQuery)) relevance += 3;
    if (product.description.toLowerCase().contains(lowerQuery)) relevance += 2;
    if (product.descriptionEn.toLowerCase().contains(lowerQuery)) relevance += 2;
    if (product.tags.any((tag) => tag.toLowerCase().contains(lowerQuery))) relevance += 1;
    if (product.tagsEn.any((tag) => tag.toLowerCase().contains(lowerQuery))) relevance += 1;
    if (product.isFeatured) relevance += 1;
    
    return relevance;
  }

  Stream<List<Product>> watchProductsByCategory(String categoryId) {
    try {
      LoggerService.info('Starting to watch products for category: $categoryId');
      
      return _firestore
          .collection(_collection)
          .where('categoryId', isEqualTo: categoryId)
          .where('isActive', isEqualTo: true)
          .orderBy('isFeatured', descending: true)
          .orderBy('sortOrder')
          .orderBy('title')
          .snapshots()
          .map((snapshot) {
            final products = snapshot.docs
                .map((doc) => Product.fromFirestore(doc.data(), doc.id))
                .toList();
            
            LoggerService.info('Products stream updated: ${products.length} products');
            return products;
          });
    } catch (e) {
      LoggerService.error('Error watching products: $e');
      throw Exception('Failed to watch products: $e');
    }
  }

  Stream<List<Product>> watchFeaturedProducts({int limit = 10}) {
    try {
      LoggerService.info('Starting to watch featured products');
      
      return _firestore
          .collection(_collection)
          .where('isFeatured', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .orderBy('title')
          .limit(limit)
          .snapshots()
          .map((snapshot) {
            final products = snapshot.docs
                .map((doc) => Product.fromFirestore(doc.data(), doc.id))
                .toList();
            
            LoggerService.info('Featured products stream updated: ${products.length} products');
            return products;
          });
    } catch (e) {
      LoggerService.error('Error watching featured products: $e');
      throw Exception('Failed to watch featured products: $e');
    }
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

final allProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  return repository.getAllProducts();
});

final productsByCategoryProvider = FutureProvider.family<List<Product>, String>((ref, categoryId) async {
  final repository = ref.read(productRepositoryProvider);
  return repository.getProductsByCategory(categoryId);
});

final featuredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  return repository.getFeaturedProducts();
});

final recentProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.read(productRepositoryProvider);
  return repository.getRecentProducts();
});

final productByIdProvider = FutureProvider.family<Product?, String>((ref, id) async {
  final repository = ref.read(productRepositoryProvider);
  return repository.getProductById(id);
});

final searchProductsProvider = FutureProvider.family<List<Product>, Map<String, String>>((ref, params) async {
  final repository = ref.read(productRepositoryProvider);
  final query = params['query'] ?? '';
  final categoryId = params['categoryId'];
  return repository.searchProducts(query, categoryId: categoryId);
});

final productsByCategoryStreamProvider = StreamProvider.family<List<Product>, String>((ref, categoryId) {
  final repository = ref.read(productRepositoryProvider);
  return repository.watchProductsByCategory(categoryId);
});

final featuredProductsStreamProvider = StreamProvider<List<Product>>((ref) {
  final repository = ref.read(productRepositoryProvider);
  return repository.watchFeaturedProducts();
});

final productCountByCategoryProvider = FutureProvider.family<int, String>((ref, categoryId) async {
  final products = await ref.read(productsByCategoryProvider(categoryId).future);
  return products.length;
});