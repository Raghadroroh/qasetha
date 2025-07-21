import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';

  // Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        // Check if profileCompletion field exists, if not add it
        if (!data.containsKey('profileCompletion')) {
          await _addProfileCompletionField(userId);
          // Re-fetch the document with the new field
          final updatedDoc = await _firestore
              .collection(_usersCollection)
              .doc(userId)
              .get();
          return UserProfile.fromFirestore(updatedDoc);
        }

        return UserProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Add profileCompletion field to existing user
  Future<void> _addProfileCompletionField(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'profileCompletion': {
          'percentage': 0.0,
          'missingFields': [],
          'hasSeenWelcomeModal': false,
          'lastPromptDate': null,
          'isBasicInfoComplete': false,
          'isEmploymentInfoComplete': false,
          'isAddressInfoComplete': false,
          'hasProfileImage': false,
        },
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add profile completion field: $e');
    }
  }

  // Create a complete user profile with all required fields
  Future<UserProfile> createCompleteUserProfile({
    required String userId,
    required String email,
    required String fullName,
    required String phoneNumber,
    String? profileImage,
    String userType = 'customer',
    String nationalId = '',
    Employment? employment,
    Address? address,
    double creditLimit = 0.0,
    double availableCredit = 0.0,
    double totalDebt = 0.0,
    double rating = 0.0,
    bool isVerified = false,
  }) async {
    try {
      final now = DateTime.now();
      final profile = UserProfile(
        userId: userId,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        profileImage: profileImage,
        userType: userType,
        nationalId: nationalId,
        employment:
            employment ??
            Employment(
              isEmployed: false,
              sector: 'none',
              employerName: '',
              jobTitle: '',
              employeeId: null,
            ),
        address:
            address ??
            Address(street: '', city: '', governorate: '', postalCode: ''),
        creditLimit: creditLimit,
        availableCredit: availableCredit,
        totalDebt: totalDebt,
        rating: rating,
        isVerified: isVerified,
        createdAt: now,
        updatedAt: now,
        profileCompletion: ProfileCompletion(
          percentage: 0.0,
          missingFields: [],
          hasSeenWelcomeModal: false,
          lastPromptDate: null,
          isBasicInfoComplete: false,
          isEmploymentInfoComplete: false,
          isAddressInfoComplete: false,
          hasProfileImage: false,
        ),
      );

      await createUserProfile(profile);
      return profile;
    } catch (e) {
      throw Exception('Failed to create complete user profile: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update(data);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }
  
  // Update user profile with UserProfile object
  Future<void> updateUserProfileObject(UserProfile profile) async {
    try {
      final data = profile.toMap();
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection(_usersCollection).doc(profile.userId).update(data);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Create user profile
  Future<void> createUserProfile(UserProfile userProfile) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userProfile.userId)
          .set(userProfile.toMap());
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  // Delete user profile
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user profile: $e');
    }
  }

  // Get credit history
  Future<List<CreditHistoryEntry>> getCreditHistory(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('creditHistory')
          .orderBy('date', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => CreditHistoryEntry.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get credit history: $e');
    }
  }

  // Add credit history entry
  Future<void> addCreditHistoryEntry(
    String userId,
    CreditHistoryEntry entry,
  ) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection('creditHistory')
          .add(entry.toMap());
    } catch (e) {
      throw Exception('Failed to add credit history entry: $e');
    }
  }

  // Update credit information
  Future<void> updateCreditInfo(
    String userId, {
    double? creditLimit,
    double? availableCredit,
    double? totalDebt,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};

      if (creditLimit != null) updateData['creditLimit'] = creditLimit;
      if (availableCredit != null) {
        updateData['availableCredit'] = availableCredit;
      }
      if (totalDebt != null) updateData['totalDebt'] = totalDebt;

      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update credit info: $e');
    }
  }

  // Update user rating
  Future<void> updateUserRating(String userId, double rating) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'rating': rating,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user rating: $e');
    }
  }

  // Verify user account
  Future<void> verifyUser(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'isVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to verify user: $e');
    }
  }

  // Get user by email
  Future<UserProfile?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserProfile.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user by email: $e');
    }
  }

  // Get user by phone number
  Future<UserProfile?> getUserByPhone(String phoneNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserProfile.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user by phone: $e');
    }
  }

  // Stream user profile changes
  Stream<UserProfile?> getUserProfileStream(String userId) {
    return _firestore.collection(_usersCollection).doc(userId).snapshots().map((
      doc,
    ) {
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    });
  }

  // Update profile image
  Future<void> updateProfileImage(String userId, String imageUrl) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'profileImage': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update profile image: $e');
    }
  }

  // Remove profile image
  Future<void> removeProfileImage(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'profileImage': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to remove profile image: $e');
    }
  }

  // Get users by criteria (for admin)
  Future<List<UserProfile>> getUsers({
    int limit = 20,
    DocumentSnapshot? lastDocument,
    String? userType,
    bool? isVerified,
  }) async {
    try {
      Query query = _firestore.collection(_usersCollection);

      if (userType != null) {
        query = query.where('userType', isEqualTo: userType);
      }

      if (isVerified != null) {
        query = query.where('isVerified', isEqualTo: isVerified);
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  // Search users
  Future<List<UserProfile>> searchUsers(String searchTerm) async {
    try {
      final querySnapshot = await _firestore
          .collection(_usersCollection)
          .where('fullName', isGreaterThanOrEqualTo: searchTerm)
          .where('fullName', isLessThan: '$searchTerm\uf8ff')
          .limit(20)
          .get();

      return querySnapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }
}
