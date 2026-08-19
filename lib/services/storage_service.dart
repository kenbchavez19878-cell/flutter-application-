import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static const String _storageKey = 'epc_techstock_data';

  Future<void> saveData({
    required AppSettings settings,
    required List<Product> inventory,
    required List<SaleRecord> salesHistory,
    required List<String> categories,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'appSettings': settings.toJson(),
      'inventory': inventory.map((p) => p.toJson()).toList(),
      'salesHistory': salesHistory.map((s) => s.toJson()).toList(),
      'categories': categories,
    };
    await prefs.setString(_storageKey, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
