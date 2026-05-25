import 'package:intl/intl.dart';

class Payment {
  final int? id;
  final double montant;
  final DateTime mois; // represents a LocalDate on backend (use yyyy-MM-dd)
  final bool isPaid;
  final int? playerId;
  final int? parentId;

  Payment({
    this.id,
    required this.montant,
    required this.mois,
    this.isPaid = false,
    this.playerId,
    this.parentId,
  });

  /// Parse from backend JSON. Handles different naming variants gracefully.
  factory Payment.fromJson(Map<String, dynamic> json) {
    // helper to read numeric fields that might be int/double/string
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) {
        return double.tryParse(v) ?? 0.0;
      }
      return 0.0;
    }

    // parse date: backend uses LocalDate -> typically yyyy-MM-dd
    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.now();
      if (v is DateTime) return v;
      if (v is String) {
        // Accept ISO with time or only date
        try {
          // If full ISO timestamp, DateTime.parse works
          return DateTime.parse(v);
        } catch (_) {
          // try yyyy-MM-dd
          try {
            return DateTime.parse(v + 'T00:00:00');
          } catch (_) {
            return DateTime.now();
          }
        }
      }
      // some servers return epoch millis
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return DateTime.now();
    }

    bool _parseBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is int) return v != 0;
      if (v is String) {
        final s = v.toLowerCase();
        return s == 'true' || s == '1' || s == 'yes';
      }
      return false;
    }

    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    // Accept both camelCase and snake_case names
    dynamic getField(String a, String b) {
      if (json.containsKey(a)) return json[a];
      if (json.containsKey(b)) return json[b];
      return null;
    }

    final montantRaw = getField('montant', 'amount');
    final moisRaw = getField('mois', 'month');
    final isPaidRaw = getField('isPaid', 'is_paid') ?? getField('paid', 'paid');
    final playerIdRaw = getField('playerId', 'player_id');
    final parentIdRaw = getField('parentId', 'parent_id');

    return Payment(
      id: _toInt(getField('id', 'Id') ?? getField('paymentId', 'payment_id')),
      montant: _toDouble(montantRaw),
      mois: _parseDate(moisRaw),
      isPaid: _parseBool(isPaidRaw),
      playerId: _toInt(playerIdRaw),
      parentId: _toInt(parentIdRaw),
    );
  }

  /// Convert to JSON expected by backend `Payment` entity:
  /// { "montant": 100.0, "mois": "2025-11-01", "playerId": 12, "parentId": 5, "isPaid": false }
  Map<String, dynamic> toJson() {
    final DateFormat fmt = DateFormat('yyyy-MM-dd');
    return {
      if (id != null) 'id': id,
      'montant': montant,
      'mois': fmt.format(mois),
      'isPaid': isPaid,
      if (playerId != null) 'playerId': playerId,
      if (parentId != null) 'parentId': parentId,
    };
  }

  Payment copyWith({
    int? id,
    double? montant,
    DateTime? mois,
    bool? isPaid,
    int? playerId,
    int? parentId,
  }) {
    return Payment(
      id: id ?? this.id,
      montant: montant ?? this.montant,
      mois: mois ?? this.mois,
      isPaid: isPaid ?? this.isPaid,
      playerId: playerId ?? this.playerId,
      parentId: parentId ?? this.parentId,
    );
  }
}


