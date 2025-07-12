class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  // TODO: سيتم إضافة FirebasePerformance instance هنا بعد التهيئة

  Future<void> setPerformanceCollectionEnabled(bool enabled) async {
    // TODO: سيتم تنفيذ تفعيل/إلغاء تفعيل مراقبة الأداء بعد تهيئة Firebase
  }

  PerformanceTrace newTrace(String name) {
    // TODO: سيتم تنفيذ إنشاء trace جديد بعد تهيئة Firebase
    return PerformanceTrace(name);
  }

  HttpMetric newHttpMetric(String url, String httpMethod) {
    // TODO: سيتم تنفيذ إنشاء HTTP metric جديد بعد تهيئة Firebase
    return HttpMetric(url, httpMethod);
  }
}

class PerformanceTrace {
  final String name;
  
  PerformanceTrace(this.name);

  Future<void> start() async {
    // TODO: سيتم تنفيذ بدء التتبع بعد تهيئة Firebase
  }

  Future<void> stop() async {
    // TODO: سيتم تنفيذ إيقاف التتبع بعد تهيئة Firebase
  }

  void putAttribute(String name, String value) {
    // TODO: سيتم تنفيذ إضافة خاصية للتتبع بعد تهيئة Firebase
  }

  void incrementMetric(String name, int value) {
    // TODO: سيتم تنفيذ زيادة قيمة المقياس بعد تهيئة Firebase
  }
}

class HttpMetric {
  final String url;
  final String httpMethod;
  
  HttpMetric(this.url, this.httpMethod);

  Future<void> start() async {
    // TODO: سيتم تنفيذ بدء مراقبة HTTP بعد تهيئة Firebase
  }

  Future<void> stop() async {
    // TODO: سيتم تنفيذ إيقاف مراقبة HTTP بعد تهيئة Firebase
  }

  void putAttribute(String name, String value) {
    // TODO: سيتم تنفيذ إضافة خاصية لمراقبة HTTP بعد تهيئة Firebase
  }

  set httpResponseCode(int? code) {
    // TODO: سيتم تنفيذ تعيين رمز الاستجابة بعد تهيئة Firebase
  }

  set requestPayloadSize(int? size) {
    // TODO: سيتم تنفيذ تعيين حجم الطلب بعد تهيئة Firebase
  }

  set responsePayloadSize(int? size) {
    // TODO: سيتم تنفيذ تعيين حجم الاستجابة بعد تهيئة Firebase
  }
}