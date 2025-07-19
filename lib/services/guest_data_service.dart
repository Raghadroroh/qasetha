import '../services/secure_storage_service.dart';
import '../services/logger_service.dart';
import 'dart:convert';

class GuestDataService {
  static const String _cartKey = 'guest_cart';
  static const String _wishlistKey = 'guest_wishlist';
  static const String _preferencesKey = 'guest_preferences';
  static const String _viewHistoryKey = 'guest_view_history';
  static const String _searchHistoryKey = 'guest_search_history';

  // Cart Management
  static Future<void> saveCartItem(String productId, Map<String, dynamic> item) async {
    try {
      final cart = await getCart();
      cart[productId] = item;
      await SecureStorageService.saveData(_cartKey, jsonEncode(cart));
      LoggerService.info('Cart item saved for guest user');
    } catch (e) {
      LoggerService.error('Error saving cart item: $e');
    }
  }

  static Future<void> removeCartItem(String productId) async {
    try {
      final cart = await getCart();
      cart.remove(productId);
      await SecureStorageService.saveData(_cartKey, jsonEncode(cart));
      LoggerService.info('Cart item removed for guest user');
    } catch (e) {
      LoggerService.error('Error removing cart item: $e');
    }
  }

  static Future<Map<String, dynamic>> getCart() async {
    try {
      final cartData = await SecureStorageService.getData(_cartKey);
      if (cartData != null) {
        return Map<String, dynamic>.from(jsonDecode(cartData));
      }
      return {};
    } catch (e) {
      LoggerService.error('Error getting cart: $e');
      return {};
    }
  }

  static Future<void> clearCart() async {
    try {
      await SecureStorageService.deleteData(_cartKey);
      LoggerService.info('Guest cart cleared');
    } catch (e) {
      LoggerService.error('Error clearing cart: $e');
    }
  }

  // Wishlist Management
  static Future<void> addToWishlist(String productId) async {
    try {
      final wishlist = await getWishlist();
      if (!wishlist.contains(productId)) {
        wishlist.add(productId);
        await SecureStorageService.saveData(_wishlistKey, jsonEncode(wishlist));
        LoggerService.info('Product added to guest wishlist');
      }
    } catch (e) {
      LoggerService.error('Error adding to wishlist: $e');
    }
  }

  static Future<void> removeFromWishlist(String productId) async {
    try {
      final wishlist = await getWishlist();
      wishlist.remove(productId);
      await SecureStorageService.saveData(_wishlistKey, jsonEncode(wishlist));
      LoggerService.info('Product removed from guest wishlist');
    } catch (e) {
      LoggerService.error('Error removing from wishlist: $e');
    }
  }

  static Future<List<String>> getWishlist() async {
    try {
      final wishlistData = await SecureStorageService.getData(_wishlistKey);
      if (wishlistData != null) {
        return List<String>.from(jsonDecode(wishlistData));
      }
      return [];
    } catch (e) {
      LoggerService.error('Error getting wishlist: $e');
      return [];
    }
  }

  static Future<void> clearWishlist() async {
    try {
      await SecureStorageService.deleteData(_wishlistKey);
      LoggerService.info('Guest wishlist cleared');
    } catch (e) {
      LoggerService.error('Error clearing wishlist: $e');
    }
  }

  // Preferences Management
  static Future<void> savePreference(String key, dynamic value) async {
    try {
      final preferences = await getPreferences();
      preferences[key] = value;
      await SecureStorageService.saveData(_preferencesKey, jsonEncode(preferences));
      LoggerService.info('Guest preference saved: $key');
    } catch (e) {
      LoggerService.error('Error saving preference: $e');
    }
  }

  static Future<T?> getPreference<T>(String key) async {
    try {
      final preferences = await getPreferences();
      return preferences[key] as T?;
    } catch (e) {
      LoggerService.error('Error getting preference: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> getPreferences() async {
    try {
      final preferencesData = await SecureStorageService.getData(_preferencesKey);
      if (preferencesData != null) {
        return Map<String, dynamic>.from(jsonDecode(preferencesData));
      }
      return {};
    } catch (e) {
      LoggerService.error('Error getting preferences: $e');
      return {};
    }
  }

  static Future<void> clearPreferences() async {
    try {
      await SecureStorageService.deleteData(_preferencesKey);
      LoggerService.info('Guest preferences cleared');
    } catch (e) {
      LoggerService.error('Error clearing preferences: $e');
    }
  }

  // View History Management
  static Future<void> addToViewHistory(String productId) async {
    try {
      final history = await getViewHistory();
      // Remove if already exists to move to front
      history.remove(productId);
      // Add to front
      history.insert(0, productId);
      // Keep only last 50 items
      if (history.length > 50) {
        history.removeRange(50, history.length);
      }
      await SecureStorageService.saveData(_viewHistoryKey, jsonEncode(history));
      LoggerService.info('Product added to guest view history');
    } catch (e) {
      LoggerService.error('Error adding to view history: $e');
    }
  }

  static Future<List<String>> getViewHistory() async {
    try {
      final historyData = await SecureStorageService.getData(_viewHistoryKey);
      if (historyData != null) {
        return List<String>.from(jsonDecode(historyData));
      }
      return [];
    } catch (e) {
      LoggerService.error('Error getting view history: $e');
      return [];
    }
  }

  static Future<void> clearViewHistory() async {
    try {
      await SecureStorageService.deleteData(_viewHistoryKey);
      LoggerService.info('Guest view history cleared');
    } catch (e) {
      LoggerService.error('Error clearing view history: $e');
    }
  }

  // Search History Management
  static Future<void> addToSearchHistory(String query) async {
    try {
      final history = await getSearchHistory();
      // Remove if already exists to move to front
      history.remove(query);
      // Add to front
      history.insert(0, query);
      // Keep only last 20 items
      if (history.length > 20) {
        history.removeRange(20, history.length);
      }
      await SecureStorageService.saveData(_searchHistoryKey, jsonEncode(history));
      LoggerService.info('Search query added to guest history');
    } catch (e) {
      LoggerService.error('Error adding to search history: $e');
    }
  }

  static Future<List<String>> getSearchHistory() async {
    try {
      final historyData = await SecureStorageService.getData(_searchHistoryKey);
      if (historyData != null) {
        return List<String>.from(jsonDecode(historyData));
      }
      return [];
    } catch (e) {
      LoggerService.error('Error getting search history: $e');
      return [];
    }
  }

  static Future<void> clearSearchHistory() async {
    try {
      await SecureStorageService.deleteData(_searchHistoryKey);
      LoggerService.info('Guest search history cleared');
    } catch (e) {
      LoggerService.error('Error clearing search history: $e');
    }
  }

  // Data Transfer for Account Creation
  static Future<Map<String, dynamic>> getAllGuestData() async {
    try {
      final data = {
        'cart': await getCart(),
        'wishlist': await getWishlist(),
        'preferences': await getPreferences(),
        'viewHistory': await getViewHistory(),
        'searchHistory': await getSearchHistory(),
      };
      return data;
    } catch (e) {
      LoggerService.error('Error getting all guest data: $e');
      return {};
    }
  }

  static Future<void> clearAllGuestData() async {
    try {
      await Future.wait([
        clearCart(),
        clearWishlist(),
        clearPreferences(),
        clearViewHistory(),
        clearSearchHistory(),
      ]);
      LoggerService.info('All guest data cleared');
    } catch (e) {
      LoggerService.error('Error clearing all guest data: $e');
    }
  }

  // Data Export for User Account
  static Future<void> transferDataToUserAccount(String userId) async {
    try {
      final guestData = await getAllGuestData();
      
      // Here you would typically upload the data to Firestore
      // For now, we'll just log it
      LoggerService.info('Guest data ready for transfer: ${guestData.keys.toList()}');
      
      // Clear guest data after transfer
      await clearAllGuestData();
    } catch (e) {
      LoggerService.error('Error transferring data to user account: $e');
    }
  }

  // Helper Methods
  static Future<int> getCartItemCount() async {
    try {
      final cart = await getCart();
      return cart.length;
    } catch (e) {
      return 0;
    }
  }

  static Future<int> getWishlistItemCount() async {
    try {
      final wishlist = await getWishlist();
      return wishlist.length;
    } catch (e) {
      return 0;
    }
  }

  static Future<bool> isInWishlist(String productId) async {
    try {
      final wishlist = await getWishlist();
      return wishlist.contains(productId);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isInCart(String productId) async {
    try {
      final cart = await getCart();
      return cart.containsKey(productId);
    } catch (e) {
      return false;
    }
  }

  // Data size calculation for UI
  static Future<String> getDataSizeDescription() async {
    try {
      final cart = await getCart();
      final wishlist = await getWishlist();
      final viewHistory = await getViewHistory();
      
      final totalItems = cart.length + wishlist.length + viewHistory.length;
      
      if (totalItems == 0) {
        return 'لا توجد بيانات محفوظة';
      } else if (totalItems < 10) {
        return 'بيانات قليلة ($totalItems عناصر)';
      } else if (totalItems < 50) {
        return 'بيانات متوسطة ($totalItems عناصر)';
      } else {
        return 'بيانات كثيرة ($totalItems عناصر)';
      }
    } catch (e) {
      return 'غير معروف';
    }
  }
}