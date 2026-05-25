import 'package:flutter/foundation.dart';
import '../models/parent.dart';
import '../services/parent_service.dart';

class ParentController extends ChangeNotifier {
  final ParentService _service = ParentService();
  List<Parent> parents = [];
  bool isLoading = false;
  String? error;

  Future<void> loadAll() async {
    isLoading = true; error = null; notifyListeners();
    try { parents = await _service.getAllParents(); }
    catch (e) { error = e.toString(); }
    finally { isLoading = false; notifyListeners(); }
  }

  Future<bool> createParent(Map<String, dynamic> body) async {
    try {
      final p = await _service.createParent(body);
      if (p != null) { parents.insert(0, p); notifyListeners(); return true; }
      return false;
    } catch (e) { error = e.toString(); notifyListeners(); return false; }
  }

  Future<bool> updateParent(int id, Map<String, dynamic> body) async {
    try {
      final p = await _service.updateParent(id, body);
      if (p != null) {
        final i = parents.indexWhere((x) => x.id == id);
        if (i >= 0) parents[i] = p;
        notifyListeners(); return true;
      }
      return false;
    } catch (e) { error = e.toString(); notifyListeners(); return false; }
  }

  Future<bool> deleteParent(int id) async {
    try {
      final ok = await _service.deleteParent(id);
      if (ok) { parents.removeWhere((x) => x.id == id); notifyListeners(); }
      return ok;
    } catch (e) { error = e.toString(); notifyListeners(); return false; }
  }
}


