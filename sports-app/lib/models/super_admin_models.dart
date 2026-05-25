class SuperAdminAcademy {
  final int id;
  final String name;
  final String slug;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String country;
  final String status;
  final String logoUrl;
  final String subscriptionOffer;
  final String subscriptionPaymentStatus;
  final int? sportId;
  final String sportName;

  const SuperAdminAcademy({
    required this.id,
    required this.name,
    this.slug = '',
    this.email = '',
    this.phone = '',
    this.address = '',
    this.city = '',
    this.country = '',
    this.status = 'ACTIVE',
    this.logoUrl = '',
    this.subscriptionOffer = 'REGULAR',
    this.subscriptionPaymentStatus = 'PENDING',
    this.sportId,
    this.sportName = '',
  });

  factory SuperAdminAcademy.fromJson(Map<String, dynamic> json) {
    final sport = _asMap(json['sport']);
    return SuperAdminAcademy(
      id: _toInt(json['id']) ?? 0,
      name: _text(json['name'] ?? json['academyName']),
      slug: _text(json['slug']),
      email: _text(json['email']),
      phone: _text(json['phone']),
      address: _text(json['address']),
      city: _text(json['city']),
      country: _text(json['country']),
      status: _text(json['status'], fallback: 'ACTIVE'),
      logoUrl: _text(json['logoUrl']),
      subscriptionOffer: _text(json['subscriptionOffer'], fallback: 'REGULAR'),
      subscriptionPaymentStatus: _text(
        json['subscriptionPaymentStatus'],
        fallback: 'PENDING',
      ),
      sportId: _toInt(json['sportId'] ?? sport?['id']),
      sportName: _text(json['sportName'] ?? sport?['name']),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'name': name,
      'slug': slug,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'country': country,
      'status': status,
      'logoUrl': logoUrl,
      if (sportId != null) 'sportId': sportId,
    };
  }
}

class SuperAdminSport {
  final int id;
  final String code;
  final String name;
  final String description;
  final bool isActive;
  final int displayOrder;
  final int? themeId;

  const SuperAdminSport({
    required this.id,
    this.code = '',
    required this.name,
    this.description = '',
    this.isActive = true,
    this.displayOrder = 0,
    this.themeId,
  });

  factory SuperAdminSport.fromJson(Map<String, dynamic> json) {
    final sport = _asMap(json['sport']) ?? json;
    return SuperAdminSport(
      id: _toInt(sport['id']) ?? 0,
      code: _text(sport['code']),
      name: _text(sport['name']),
      description: _text(sport['description']),
      isActive: _toBool(sport['isActive'] ?? sport['active'], fallback: true),
      displayOrder: _toInt(sport['displayOrder']) ?? 0,
      themeId: _toInt(json['themeId'] ?? sport['themeId']),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'isActive': isActive,
      'displayOrder': displayOrder,
    };
  }
}

class SuperAdminSportCategory {
  final int id;
  final String code;
  final String name;
  final String description;
  final int? sportId;
  final String sportName;
  final bool isActive;
  final int displayOrder;

  const SuperAdminSportCategory({
    required this.id,
    this.code = '',
    required this.name,
    this.description = '',
    this.sportId,
    this.sportName = '',
    this.isActive = true,
    this.displayOrder = 0,
  });

  factory SuperAdminSportCategory.fromJson(Map<String, dynamic> json) {
    final sport = _asMap(json['sport']);
    return SuperAdminSportCategory(
      id: _toInt(json['id']) ?? 0,
      code: _text(json['code']),
      name: _text(json['name']),
      description: _text(json['description']),
      sportId: _toInt(json['sportId'] ?? sport?['id']),
      sportName: _text(json['sportName'] ?? sport?['name']),
      isActive: _toBool(json['isActive'] ?? json['active'], fallback: true),
      displayOrder: _toInt(json['displayOrder']) ?? 0,
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'sportId': sportId,
      'isActive': isActive,
      'displayOrder': displayOrder,
    };
  }
}

class PlatformContact {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final int? academyId;
  final String academyName;
  final bool active;

  const PlatformContact({
    required this.id,
    this.name = '',
    this.email = '',
    this.phone = '',
    this.role = '',
    this.academyId,
    this.academyName = '',
    this.active = true,
  });

  factory PlatformContact.fromJson(Map<String, dynamic> json) {
    return PlatformContact(
      id: _toInt(json['id']) ?? 0,
      name: _text(json['name'] ?? json['nom']),
      email: _text(json['email']),
      phone: _text(json['phone'] ?? json['tel']),
      role: _text(json['role'] ?? json['mainRole']),
      academyId: _toInt(json['academyId']),
      academyName: _text(json['academyName']),
      active: _toBool(json['active'], fallback: true),
    );
  }
}

class AcademyContactGroup {
  final int academyId;
  final String academyName;
  final String city;
  final String country;
  final PlatformContact? ownerUser;
  final List<PlatformContact> admins;

  const AcademyContactGroup({
    required this.academyId,
    required this.academyName,
    this.city = '',
    this.country = '',
    this.ownerUser,
    this.admins = const [],
  });

  factory AcademyContactGroup.fromJson(Map<String, dynamic> json) {
    final adminsRaw = json['admins'];
    return AcademyContactGroup(
      academyId: _toInt(json['academyId']) ?? 0,
      academyName: _text(json['academyName']),
      city: _text(json['city']),
      country: _text(json['country']),
      ownerUser:
          _asMap(json['ownerUser']) == null
              ? null
              : PlatformContact.fromJson(_asMap(json['ownerUser'])!),
      admins:
          adminsRaw is List
              ? adminsRaw
                  .whereType<Map>()
                  .map(
                    (e) =>
                        PlatformContact.fromJson(Map<String, dynamic>.from(e)),
                  )
                  .toList()
              : const [],
    );
  }
}

class AcademyPaymentItem {
  final int id;
  final int? academyId;
  final String academyName;
  final String offer;
  final double amount;
  final String currency;
  final String status;
  final String paymentMethod;
  final String referenceCode;
  final String notes;
  final String dueDate;
  final String paidAt;
  final String createdAt;

  const AcademyPaymentItem({
    required this.id,
    this.academyId,
    this.academyName = '',
    this.offer = '',
    this.amount = 0,
    this.currency = 'TND',
    this.status = 'PENDING',
    this.paymentMethod = 'MANUAL',
    this.referenceCode = '',
    this.notes = '',
    this.dueDate = '',
    this.paidAt = '',
    this.createdAt = '',
  });

  factory AcademyPaymentItem.fromJson(Map<String, dynamic> json) {
    return AcademyPaymentItem(
      id: _toInt(json['id']) ?? 0,
      academyId: _toInt(json['academyId']),
      academyName: _text(json['academyName']),
      offer: _text(json['offer']),
      amount: _toDouble(json['amount']) ?? 0,
      currency: _text(json['currency'], fallback: 'TND'),
      status: _text(json['status'], fallback: 'PENDING'),
      paymentMethod: _text(json['paymentMethod'], fallback: 'MANUAL'),
      referenceCode: _text(json['referenceCode']),
      notes: _text(json['notes']),
      dueDate: _text(json['dueDate']),
      paidAt: _text(json['paidAt']),
      createdAt: _text(json['createdAt']),
    );
  }

  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isPaid => status.toUpperCase() == 'PAID';
}

class WebhookItem {
  final int id;
  final String name;
  final String url;
  final String eventType;
  final bool isActive;
  final String httpMethod;
  final String headers;
  final String authentication;
  final String lastTriggeredAt;
  final int triggerCount;

  const WebhookItem({
    required this.id,
    required this.name,
    required this.url,
    required this.eventType,
    this.isActive = true,
    this.httpMethod = 'POST',
    this.headers = '',
    this.authentication = '',
    this.lastTriggeredAt = '',
    this.triggerCount = 0,
  });

  factory WebhookItem.fromJson(Map<String, dynamic> json) {
    return WebhookItem(
      id: _toInt(json['id']) ?? 0,
      name: _text(json['name']),
      url: _text(json['url']),
      eventType: _text(json['eventType']),
      isActive: _toBool(json['isActive'] ?? json['active'], fallback: true),
      httpMethod: _text(json['httpMethod'], fallback: 'POST'),
      headers: _text(json['headers']),
      authentication: _text(json['authentication']),
      lastTriggeredAt: _text(json['lastTriggeredAt']),
      triggerCount: _toInt(json['triggerCount']) ?? 0,
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'name': name,
      'url': url,
      'eventType': eventType,
      'isActive': isActive,
      'httpMethod': httpMethod,
      'headers': headers,
      'authentication': authentication,
    };
  }
}

class WebhookLogItem {
  final int id;
  final String webhookName;
  final String eventType;
  final int statusCode;
  final bool success;
  final String errorMessage;
  final String executedAt;
  final int responseTimeMs;

  const WebhookLogItem({
    required this.id,
    this.webhookName = '',
    this.eventType = '',
    this.statusCode = 0,
    this.success = false,
    this.errorMessage = '',
    this.executedAt = '',
    this.responseTimeMs = 0,
  });

  factory WebhookLogItem.fromJson(Map<String, dynamic> json) {
    final webhook = _asMap(json['webhook']);
    return WebhookLogItem(
      id: _toInt(json['id']) ?? 0,
      webhookName: _text(json['webhookName'] ?? webhook?['name']),
      eventType: _text(json['eventType']),
      statusCode: _toInt(json['statusCode']) ?? 0,
      success: _toBool(json['success']),
      errorMessage: _text(json['errorMessage']),
      executedAt: _text(json['executedAt']),
      responseTimeMs: _toInt(json['responseTimeMs']) ?? 0,
    );
  }
}

class ChatbotKnowledgeEntry {
  final int id;
  final String question;
  final String answer;
  final String tags;
  final String scope;
  final int? academyId;
  final int? sportId;

  const ChatbotKnowledgeEntry({
    required this.id,
    this.question = '',
    this.answer = '',
    this.tags = '',
    this.scope = '',
    this.academyId,
    this.sportId,
  });

  factory ChatbotKnowledgeEntry.fromJson(Map<String, dynamic> json) {
    return ChatbotKnowledgeEntry(
      id: _toInt(json['id']) ?? 0,
      question: _text(json['question']),
      answer: _text(json['answer']),
      tags: _text(json['tags']),
      scope: _text(json['scope']),
      academyId: _toInt(json['academyId']),
      sportId: _toInt(json['sportId']),
    );
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

String _text(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? fallback : text;
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool _toBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  final text = value.toString().trim().toLowerCase();
  return text == 'true' || text == '1' || text == 'active' || text == 'yes';
}


