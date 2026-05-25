import 'role.dart';

/// Contact list item can be a USER or a GROUP (division group chat).
class ChatContact {
  final int id;
  final String name;
  final String? email;
  final String? role;
  final int? divisionId;

  /// 'USER' or 'GROUP'
  final String kind;

  /// For GROUP contacts
  final int? conversationId;

  ChatContact({
    required this.id,
    required this.name,
    this.email,
    this.role,
    this.divisionId,
    this.kind = 'USER',
    this.conversationId,
  });

  bool get isGroup => kind.toUpperCase() == 'GROUP';

  Role get parsedRole => RoleParsing.fromString(role);

  factory ChatContact.fromJson(Map<String, dynamic> json) {
    return ChatContact(
      id: int.tryParse((json['id'] ?? 0).toString()) ?? 0,
      name: (json['name'] ?? json['nom'] ?? '').toString(),
      email: json['email']?.toString(),
      role: json['role']?.toString(),
      divisionId: json['divisionId'] == null ? null : int.tryParse(json['divisionId'].toString()),
      kind: (json['kind'] ?? 'USER').toString(),
      conversationId: json['conversationId'] == null ? null : int.tryParse(json['conversationId'].toString()),
    );
  }
}


