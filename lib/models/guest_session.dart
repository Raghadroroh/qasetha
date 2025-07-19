import 'package:cloud_firestore/cloud_firestore.dart';

class GuestSession {
  final String id;
  final DateTime createdAt;
  final DateTime lastActivity;
  final int sessionCount;
  final List<String> featuresUsed;
  final Map<String, dynamic> analytics;
  final bool hasSeenWelcomeMessage;
  final bool hasSeenConversionPrompt;
  final DateTime? lastConversionPrompt;
  final int conversionPromptCount;
  final String? lastPage;
  final Map<String, int> pageVisitCount;
  final Map<String, dynamic> temporaryData;
  final bool isGuest;

  GuestSession({
    required this.id,
    required this.createdAt,
    required this.lastActivity,
    this.sessionCount = 1,
    this.featuresUsed = const [],
    this.analytics = const {},
    this.hasSeenWelcomeMessage = false,
    this.hasSeenConversionPrompt = false,
    this.lastConversionPrompt,
    this.conversionPromptCount = 0,
    this.lastPage,
    this.pageVisitCount = const {},
    this.temporaryData = const {},
    this.isGuest = true,
  });

  factory GuestSession.create() {
    final now = DateTime.now();
    return GuestSession(
      id: 'guest_${now.millisecondsSinceEpoch}',
      createdAt: now,
      lastActivity: now,
      sessionCount: 1,
      featuresUsed: [],
      analytics: {
        'firstLogin': now.toIso8601String(),
        'totalTimeSpent': 0,
        'actionsPerformed': 0,
      },
      hasSeenWelcomeMessage: false,
      hasSeenConversionPrompt: false,
      conversionPromptCount: 0,
      pageVisitCount: {},
      temporaryData: {},
    );
  }

  GuestSession copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? lastActivity,
    int? sessionCount,
    List<String>? featuresUsed,
    Map<String, dynamic>? analytics,
    bool? hasSeenWelcomeMessage,
    bool? hasSeenConversionPrompt,
    DateTime? lastConversionPrompt,
    int? conversionPromptCount,
    String? lastPage,
    Map<String, int>? pageVisitCount,
    Map<String, dynamic>? temporaryData,
    bool? isGuest,
  }) {
    return GuestSession(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
      sessionCount: sessionCount ?? this.sessionCount,
      featuresUsed: featuresUsed ?? this.featuresUsed,
      analytics: analytics ?? this.analytics,
      hasSeenWelcomeMessage: hasSeenWelcomeMessage ?? this.hasSeenWelcomeMessage,
      hasSeenConversionPrompt: hasSeenConversionPrompt ?? this.hasSeenConversionPrompt,
      lastConversionPrompt: lastConversionPrompt ?? this.lastConversionPrompt,
      conversionPromptCount: conversionPromptCount ?? this.conversionPromptCount,
      lastPage: lastPage ?? this.lastPage,
      pageVisitCount: pageVisitCount ?? this.pageVisitCount,
      temporaryData: temporaryData ?? this.temporaryData,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
      'sessionCount': sessionCount,
      'featuresUsed': featuresUsed,
      'analytics': analytics,
      'hasSeenWelcomeMessage': hasSeenWelcomeMessage,
      'hasSeenConversionPrompt': hasSeenConversionPrompt,
      'lastConversionPrompt': lastConversionPrompt?.toIso8601String(),
      'conversionPromptCount': conversionPromptCount,
      'lastPage': lastPage,
      'pageVisitCount': pageVisitCount,
      'temporaryData': temporaryData,
      'isGuest': isGuest,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSeen': Timestamp.fromDate(lastActivity),
      'isGuest': isGuest,
      'sessionCount': sessionCount,
      'featuresUsed': featuresUsed,
      'analytics': analytics,
      'hasSeenWelcomeMessage': hasSeenWelcomeMessage,
      'hasSeenConversionPrompt': hasSeenConversionPrompt,
      'lastConversionPrompt': lastConversionPrompt != null ? Timestamp.fromDate(lastConversionPrompt!) : null,
      'conversionPromptCount': conversionPromptCount,
      'lastPage': lastPage,
      'pageVisitCount': pageVisitCount,
      'temporaryData': temporaryData,
    };
  }

  factory GuestSession.fromJson(Map<String, dynamic> json) {
    return GuestSession(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      lastActivity: DateTime.parse(json['lastActivity']),
      sessionCount: json['sessionCount'] ?? 1,
      featuresUsed: List<String>.from(json['featuresUsed'] ?? []),
      analytics: Map<String, dynamic>.from(json['analytics'] ?? {}),
      hasSeenWelcomeMessage: json['hasSeenWelcomeMessage'] ?? false,
      hasSeenConversionPrompt: json['hasSeenConversionPrompt'] ?? false,
      lastConversionPrompt: json['lastConversionPrompt'] != null
          ? DateTime.parse(json['lastConversionPrompt'])
          : null,
      conversionPromptCount: json['conversionPromptCount'] ?? 0,
      lastPage: json['lastPage'],
      pageVisitCount: Map<String, int>.from(json['pageVisitCount'] ?? {}),
      temporaryData: Map<String, dynamic>.from(json['temporaryData'] ?? {}),
      isGuest: json['isGuest'] ?? true,
    );
  }

  factory GuestSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GuestSession(
      id: doc.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActivity: (data['lastSeen'] as Timestamp).toDate(),
      sessionCount: data['sessionCount'] ?? 1,
      featuresUsed: List<String>.from(data['featuresUsed'] ?? []),
      analytics: Map<String, dynamic>.from(data['analytics'] ?? {}),
      hasSeenWelcomeMessage: data['hasSeenWelcomeMessage'] ?? false,
      hasSeenConversionPrompt: data['hasSeenConversionPrompt'] ?? false,
      lastConversionPrompt: data['lastConversionPrompt'] != null
          ? (data['lastConversionPrompt'] as Timestamp).toDate()
          : null,
      conversionPromptCount: data['conversionPromptCount'] ?? 0,
      lastPage: data['lastPage'],
      pageVisitCount: Map<String, int>.from(data['pageVisitCount'] ?? {}),
      temporaryData: Map<String, dynamic>.from(data['temporaryData'] ?? {}),
      isGuest: data['isGuest'] ?? true,
    );
  }

  // Helper methods
  bool get isExpired {
    final now = DateTime.now();
    final expiry = createdAt.add(const Duration(days: 30));
    return now.isAfter(expiry);
  }

  bool get shouldShowConversionPrompt {
    if (hasSeenConversionPrompt && conversionPromptCount >= 3) {
      return false;
    }
    
    final now = DateTime.now();
    if (lastConversionPrompt != null) {
      final daysSinceLastPrompt = now.difference(lastConversionPrompt!).inDays;
      if (daysSinceLastPrompt < 1) {
        return false;
      }
    }

    // Show after 3 sessions or after using 2 features
    return sessionCount >= 3 || featuresUsed.length >= 2;
  }

  Duration get totalDuration {
    return DateTime.now().difference(createdAt);
  }

  int get totalActions {
    return analytics['actionsPerformed'] ?? 0;
  }

  // Update methods
  GuestSession incrementSession() {
    return copyWith(
      sessionCount: sessionCount + 1,
      lastActivity: DateTime.now(),
    );
  }

  GuestSession addFeatureUsed(String feature) {
    final updatedFeatures = List<String>.from(featuresUsed);
    if (!updatedFeatures.contains(feature)) {
      updatedFeatures.add(feature);
    }
    
    final updatedAnalytics = Map<String, dynamic>.from(analytics);
    updatedAnalytics['actionsPerformed'] = (updatedAnalytics['actionsPerformed'] ?? 0) + 1;
    
    return copyWith(
      featuresUsed: updatedFeatures,
      analytics: updatedAnalytics,
      lastActivity: DateTime.now(),
    );
  }

  GuestSession markConversionPromptShown() {
    return copyWith(
      hasSeenConversionPrompt: true,
      lastConversionPrompt: DateTime.now(),
      conversionPromptCount: conversionPromptCount + 1,
    );
  }

  GuestSession updatePageVisit(String page) {
    final updatedPageVisits = Map<String, int>.from(pageVisitCount);
    updatedPageVisits[page] = (updatedPageVisits[page] ?? 0) + 1;
    
    return copyWith(
      lastPage: page,
      pageVisitCount: updatedPageVisits,
      lastActivity: DateTime.now(),
    );
  }

  GuestSession updateTemporaryData(String key, dynamic value) {
    final updatedData = Map<String, dynamic>.from(temporaryData);
    updatedData[key] = value;
    
    return copyWith(
      temporaryData: updatedData,
      lastActivity: DateTime.now(),
    );
  }
}