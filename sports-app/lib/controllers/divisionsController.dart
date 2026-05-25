import 'package:flutter/foundation.dart';
import '../models/division.dart';
import '../services/division_service.dart';

class DivisionController extends ChangeNotifier {
  final DivisionService _service = DivisionService();

  /* ============================================================
   * STATE
   * ============================================================ */

  // DTO data (used by UI List Page & Detail Page)
  List<Division> summaryList = [];     // GET /api/dto/divisions
  Division? detail;                    // GET /api/dto/divisions/{id}

  // Normal API data
  List<Division> academyDivisions = [];  // GET /api/academy/divisions
  List<Division> allDivisions = [];      // GET /api/divisions
  Division? currentDivision;             // GET /api/divisions/{id}

  bool isLoading = false;
  String? error;

  /* ============================================================
   * HELPERS
   * ============================================================ */

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void _setError(String? msg) {
    error = msg;
    notifyListeners();
  }

  /* ============================================================
   * DTO LIST (Summary)
   * ============================================================ */
  Future<void> loadSummary() async {
    _setLoading(true);
    error = null;

    try {
      summaryList = await _service.getSummaryList();
    } catch (e) {
      _setError(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Division> get availableGlobalDivisions {
    final academyIds = academyDivisions.map((d) => d.id).toSet();

    return allDivisions
        .where((d) => !academyIds.contains(d.id))
        .toList()
      ..sort((a, b) => a.nom.toLowerCase().compareTo(b.nom.toLowerCase()));
  }

  Future<void> fetchAll() async {
    _setLoading(true);
    error = null;

    try {
      allDivisions = await _service.getAllDivisions();
    } catch (e) {
      _setError(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Division?> getDivisionById(int id) async {
    _setLoading(true);
    error = null;

    try {
      currentDivision = await _service.getDivisionById(id);
      return currentDivision;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

}


