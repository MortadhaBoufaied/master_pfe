enum Role {
  superAdmin,
  admin,
  trainer,
  parent,
  player,
  scouter,
  unknown,
}

/// Robust role parsing.
/// Backend may send any of:
/// - "PLAYER" (mainRole enum)
/// - "ROLE_PLAYER" (Spring Security authority)
/// - "UserRole.PLAYER" (toString of enum)
/// - "[ROLE_PLAYER, ROLE_USER]" (stringified list)
class RoleParsing {
  static Role fromString(String? value) {
    if (value == null) return Role.unknown;
    // Normalize and keep separators for contains() checks
    final raw = value.toString().trim();
    if (raw.isEmpty) return Role.unknown;

    final v = raw.toUpperCase();

    bool has(String token) {
      // matches token as whole word-ish or suffix "...TOKEN"
      if (v == token) return true;
      if (v.contains(token)) return true;
      if (v.endsWith('.$token')) return true;
      return false;
    }

    if (has('SUPER_ADMIN') || has('ROLE_SUPER_ADMIN')) return Role.superAdmin;
    if (has('ADMIN') || has('ROLE_ADMIN')) return Role.admin;
    if (has('TRAINER') || has('ROLE_TRAINER')) return Role.trainer;
    if (has('PARENT') || has('ROLE_PARENT')) return Role.parent;
    if (has('PLAYER') || has('ROLE_PLAYER')) return Role.player;
    if (has('SCOUTER') || has('ROLE_SCOUTER')) return Role.scouter;

    return Role.unknown;
  }
}


