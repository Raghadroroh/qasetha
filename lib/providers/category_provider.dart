import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../services/logger_service.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'categories';

  Future<List<Category>> getAllCategories() async {
    try {
      LoggerService.info('Fetching all categories from Firestore');
      
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .orderBy('name')
          .get();

      final categories = querySnapshot.docs
          .map((doc) => Category.fromFirestore(doc.data(), doc.id))
          .toList();

      LoggerService.info('Successfully fetched ${categories.length} categories');
      return categories;
    } catch (e) {
      LoggerService.error('Error fetching categories: $e');
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<List<Category>> getMainCategories() async {
    try {
      LoggerService.info('Fetching main categories from Firestore');
      
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('parentId', isNull: true)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .orderBy('name')
          .get();

      final categories = querySnapshot.docs
          .map((doc) => Category.fromFirestore(doc.data(), doc.id))
          .toList();

      LoggerService.info('Successfully fetched ${categories.length} main categories');
      return categories;
    } catch (e) {
      LoggerService.error('Error fetching main categories: $e');
      throw Exception('Failed to fetch main categories: $e');
    }
  }

  Future<List<Category>> getSubcategories(String parentId) async {
    try {
      LoggerService.info('Fetching subcategories for parent: $parentId');
      
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('parentId', isEqualTo: parentId)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .orderBy('name')
          .get();

      final categories = querySnapshot.docs
          .map((doc) => Category.fromFirestore(doc.data(), doc.id))
          .toList();

      LoggerService.info('Successfully fetched ${categories.length} subcategories');
      return categories;
    } catch (e) {
      LoggerService.error('Error fetching subcategories: $e');
      throw Exception('Failed to fetch subcategories: $e');
    }
  }

  Future<Category?> getCategoryById(String id) async {
    try {
      LoggerService.info('Fetching category by ID: $id');
      
      final doc = await _firestore.collection(_collection).doc(id).get();
      
      if (!doc.exists) {
        LoggerService.warning('Category not found: $id');
        return null;
      }

      final category = Category.fromFirestore(doc.data()!, doc.id);
      LoggerService.info('Successfully fetched category: ${category.name}');
      return category;
    } catch (e) {
      LoggerService.error('Error fetching category by ID: $e');
      throw Exception('Failed to fetch category: $e');
    }
  }

  Stream<List<Category>> watchAllCategories() {
    try {
      LoggerService.info('Starting to watch all categories');
      
      return _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .orderBy('name')
          .snapshots()
          .map((snapshot) {
            final categories = snapshot.docs
                .map((doc) => Category.fromFirestore(doc.data(), doc.id))
                .toList();
            
            LoggerService.info('Categories stream updated: ${categories.length} categories');
            return categories;
          });
    } catch (e) {
      LoggerService.error('Error watching categories: $e');
      throw Exception('Failed to watch categories: $e');
    }
  }

  Stream<List<Category>> watchMainCategories() {
    try {
      LoggerService.info('Starting to watch main categories');
      
      // Using only sortOrder for ordering to match the index
      // This avoids the need for a composite index with both sortOrder and name
      return _firestore
          .collection(_collection)
          .where('parentId', isNull: true)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .snapshots()
          .map((snapshot) {
            final categories = snapshot.docs
                .map((doc) => Category.fromFirestore(doc.data(), doc.id))
                .toList();
            
            // Sort by name as a secondary sort in memory instead of in the query
            categories.sort((a, b) {
              final sortOrderComparison = a.sortOrder.compareTo(b.sortOrder);
              if (sortOrderComparison != 0) return sortOrderComparison;
              return a.name.compareTo(b.name);
            });
            
            LoggerService.info('Main categories stream updated: ${categories.length} categories');
            return categories;
          });
    } catch (e) {
      LoggerService.error('Error watching main categories: $e');
      throw Exception('Failed to watch main categories: $e');
    }
  }

  Stream<List<Category>> watchSubcategories(String parentId) {
    try {
      LoggerService.info('Starting to watch subcategories for parent: $parentId');
      
      return _firestore
          .collection(_collection)
          .where('parentId', isEqualTo: parentId)
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .orderBy('name')
          .snapshots()
          .map((snapshot) {
            final categories = snapshot.docs
                .map((doc) => Category.fromFirestore(doc.data(), doc.id))
                .toList();
            
            LoggerService.info('Subcategories stream updated: ${categories.length} categories');
            return categories;
          });
    } catch (e) {
      LoggerService.error('Error watching subcategories: $e');
      throw Exception('Failed to watch subcategories: $e');
    }
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

final allCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.read(categoryRepositoryProvider);
  return repository.getAllCategories();
});

final mainCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.read(categoryRepositoryProvider);
  return repository.getMainCategories();
});

final subcategoriesProvider = FutureProvider.family<List<Category>, String>((ref, parentId) async {
  final repository = ref.read(categoryRepositoryProvider);
  return repository.getSubcategories(parentId);
});

final categoryByIdProvider = FutureProvider.family<Category?, String>((ref, id) async {
  final repository = ref.read(categoryRepositoryProvider);
  return repository.getCategoryById(id);
});

final allCategoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final repository = ref.read(categoryRepositoryProvider);
  return repository.watchAllCategories();
});

final mainCategoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final repository = ref.read(categoryRepositoryProvider);
  return repository.watchMainCategories();
});

final subcategoriesStreamProvider = StreamProvider.family<List<Category>, String>((ref, parentId) {
  final repository = ref.read(categoryRepositoryProvider);
  return repository.watchSubcategories(parentId);
});

final hasSubcategoriesProvider = FutureProvider.family<bool, String>((ref, categoryId) async {
  final subcategories = await ref.read(subcategoriesProvider(categoryId).future);
  return subcategories.isNotEmpty;
});

final categoryHierarchyProvider = FutureProvider<Map<String, List<Category>>>((ref) async {
  final allCategories = await ref.read(allCategoriesProvider.future);
  
  final Map<String, List<Category>> hierarchy = {};
  
  for (final category in allCategories) {
    final parentId = category.parentId ?? 'root';
    hierarchy.putIfAbsent(parentId, () => []);
    hierarchy[parentId]!.add(category);
  }
  
  hierarchy.forEach((key, value) {
    value.sort((a, b) {
      final sortOrderComparison = a.sortOrder.compareTo(b.sortOrder);
      if (sortOrderComparison != 0) return sortOrderComparison;
      return a.name.compareTo(b.name);
    });
  });
  
  return hierarchy;
});