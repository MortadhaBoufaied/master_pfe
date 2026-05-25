import 'dart:convert';

import '../models/super_admin_models.dart';
import 'ApiService.dart';

class SuperAdminService {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> getDashboard() async {
    return _getMap('/super-admin/mobile/dashboard');
  }

  Future<Map<String, dynamic>> getDashboardSummary() async {
    return _getMap('/super-admin/dashboard/summary');
  }

  Future<Map<String, dynamic>> recomputeAcademyRankings() async {
    return _postMap('/super-admin/dashboard/rankings/recompute', {});
  }

  Future<List<SuperAdminAcademy>> getAcademies() async {
    final list = await _getList('/super-admin/academies');
    return list.map((e) => SuperAdminAcademy.fromJson(e)).toList();
  }

  Future<SuperAdminAcademy> createAcademy(SuperAdminAcademy academy) async {
    final map = await _postMap('/super-admin/academies', academy.toPayload());
    return SuperAdminAcademy.fromJson(map);
  }

  Future<SuperAdminAcademy> updateAcademy(SuperAdminAcademy academy) async {
    final map = await _putMap(
      '/super-admin/academies/${academy.id}',
      academy.toPayload(),
    );
    return SuperAdminAcademy.fromJson(map);
  }

  Future<void> deleteAcademy(int id) async {
    await _delete('/super-admin/academies/$id');
  }

  Future<void> createAcademyAdmin({
    required int academyId,
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    await _postMap('/super-admin/academies/$academyId/admins', {
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
    });
  }

  Future<List<SuperAdminSport>> getSports({bool activeOnly = false}) async {
    final list = await _getList(activeOnly ? '/sports/active' : '/sports');
    return list.map((e) => SuperAdminSport.fromJson(e)).toList();
  }

  Future<SuperAdminSport> createSport(SuperAdminSport sport) async {
    final map = await _postMap('/sports', sport.toPayload());
    return SuperAdminSport.fromJson(map);
  }

  Future<SuperAdminSport> updateSport(SuperAdminSport sport) async {
    final map = await _putMap('/sports/${sport.id}', sport.toPayload());
    return SuperAdminSport.fromJson(map);
  }

  Future<void> deleteSport(int id) async {
    await _delete('/sports/$id');
  }

  Future<void> setSportActive(int id, bool active) async {
    await _postMap('/sports/$id/${active ? 'activate' : 'deactivate'}', {});
  }

  Future<List<SuperAdminSportCategory>> getSportCategories({
    int? sportId,
    bool activeOnly = false,
  }) async {
    final list = await _getList(
      '/super-admin/sport-categories',
      query: {
        if (sportId != null) 'sportId': sportId,
        'activeOnly': activeOnly,
      },
    );
    return list.map((e) => SuperAdminSportCategory.fromJson(e)).toList();
  }

  Future<SuperAdminSportCategory> createSportCategory(
    SuperAdminSportCategory category,
  ) async {
    final map = await _postMap(
      '/super-admin/sport-categories',
      category.toPayload(),
    );
    return SuperAdminSportCategory.fromJson(map);
  }

  Future<SuperAdminSportCategory> updateSportCategory(
    SuperAdminSportCategory category,
  ) async {
    final map = await _putMap(
      '/super-admin/sport-categories/${category.id}',
      category.toPayload(),
    );
    return SuperAdminSportCategory.fromJson(map);
  }

  Future<void> deleteSportCategory(int id) async {
    await _delete('/super-admin/sport-categories/$id');
  }

  Future<List<AcademyContactGroup>> getAdminContacts() async {
    final list = await _getList('/super-admin/mobile/admin-contacts');
    return list.map((e) => AcademyContactGroup.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getAppData() {
    return _getMap('/super-admin/mobile/app-data');
  }

  Future<Map<String, dynamic>> getSettings() {
    return _getMap('/super-admin/mobile/settings');
  }

  Future<Map<String, dynamic>> getAcademyPayments() {
    return _getMap('/super-admin/mobile/academy-payments');
  }

  Future<AcademyPaymentItem> markAcademyPaymentPaid(
    int id, {
    String paymentMethod = 'MANUAL',
    String notes = 'Approved from Flutter super-admin portal',
  }) async {
    final map = await _postMap(
      '/super-admin/mobile/academy-payments/$id/mark-paid',
      {'paymentMethod': paymentMethod, 'notes': notes},
    );
    return AcademyPaymentItem.fromJson(map);
  }

  Future<List<WebhookItem>> getWebhooks() async {
    final list = await _getList('/webhooks');
    return list.map((e) => WebhookItem.fromJson(e)).toList();
  }

  Future<List<WebhookLogItem>> getFailedWebhookLogs() async {
    final list = await _getList('/super-admin/mobile/webhook-logs/failed');
    return list.map((e) => WebhookLogItem.fromJson(e)).toList();
  }

  Future<WebhookItem> createWebhook(WebhookItem webhook) async {
    final map = await _postMap('/webhooks', webhook.toPayload());
    return WebhookItem.fromJson(map);
  }

  Future<WebhookItem> updateWebhook(WebhookItem webhook) async {
    final map = await _putMap('/webhooks/${webhook.id}', webhook.toPayload());
    return WebhookItem.fromJson(map);
  }

  Future<void> deleteWebhook(int id) async {
    await _delete('/webhooks/$id');
  }

  Future<WebhookItem> setWebhookActive(int id, bool active) async {
    final map = await _postMap(
      '/webhooks/$id/${active ? 'activate' : 'deactivate'}',
      {},
    );
    return WebhookItem.fromJson(map);
  }

  Future<Map<String, dynamic>> testWebhook(int id) {
    return _postMap('/webhooks/$id/test', {});
  }

  Future<List<ChatbotKnowledgeEntry>> getGlobalChatbotEntries() async {
    final list = await _getList('/chatbot', query: {'scope': 'GLOBAL'});
    return list.map((e) => ChatbotKnowledgeEntry.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getChatbotBootstrap() {
    return _getMap('/chatbot/admin/bootstrap');
  }

  Future<ChatbotKnowledgeEntry> teachGlobalChatbot({
    required String question,
    required String answer,
    String tags = '',
    int? replaceEntryId,
    int? uploadedById,
  }) async {
    final map = await _postMap('/chatbot/admin/teach', {
      'question': question,
      'answer': answer,
      'tags': tags,
      'scope': 'GLOBAL',
      if (replaceEntryId != null) 'replaceEntryId': replaceEntryId,
      if (uploadedById != null) 'uploadedById': uploadedById,
    });
    final entry = map['entry'];
    if (entry is Map<String, dynamic>) {
      return ChatbotKnowledgeEntry.fromJson(entry);
    }
    if (entry is Map) {
      return ChatbotKnowledgeEntry.fromJson(Map<String, dynamic>.from(entry));
    }
    return ChatbotKnowledgeEntry.fromJson(map);
  }

  Future<void> deleteChatbotEntry(int id) async {
    await _delete('/chatbot/$id');
  }

  Future<List<Map<String, dynamic>>> _getList(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await _api.get(path, query: query);
    final decoded = _decode(response.statusCode, response.bodyBytes, path);
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (decoded is Map) {
      final map = Map<String, dynamic>.from(decoded);
      final list =
          map['data'] ?? map['results'] ?? map['items'] ?? map['payments'];
      if (list is List) {
        return list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    return const [];
  }

  Future<Map<String, dynamic>> _getMap(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await _api.get(path, query: query);
    final decoded = _decode(response.statusCode, response.bodyBytes, path);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> _postMap(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _api.post(path, body: body);
    final decoded = _decode(response.statusCode, response.bodyBytes, path);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return <String, dynamic>{};
  }

  Future<Map<String, dynamic>> _putMap(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _api.put(path, body: body);
    final decoded = _decode(response.statusCode, response.bodyBytes, path);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return <String, dynamic>{};
  }

  Future<void> _delete(String path) async {
    final response = await _api.delete(path);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = utf8.decode(response.bodyBytes);
      throw Exception('$path failed: ${response.statusCode} $body');
    }
  }

  dynamic _decode(int status, List<int> bodyBytes, String path) {
    final body = utf8.decode(bodyBytes);
    if (status < 200 || status >= 300) {
      throw Exception('$path failed: $status $body');
    }
    if (body.trim().isEmpty) return null;
    return jsonDecode(body);
  }
}

