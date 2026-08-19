import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  AppSettings appSettings = AppSettings(storeName: 'EPC TechStock');
  List<Product> inventory = [];
  List<SaleRecord> salesHistory = [];
  List<String> categories = [
    'Storage',
    'Memory',
    'Peripherals',
    'Networking',
    'Components',
  ];
  List<CartItem> currentCart = [];
  List<String> activityLog = ['System initialized successfully.'];

  Future<void> loadFromStorage() async {
    final data = await _storageService.loadData();
    if (data != null) {
      appSettings = AppSettings.fromJson(data['appSettings'] ?? {});
      inventory = (data['inventory'] as List? ?? [])
          .map((p) => Product.fromJson(p as Map<String, dynamic>))
          .toList();
      salesHistory = (data['salesHistory'] as List? ?? [])
          .map((s) => SaleRecord.fromJson(s as Map<String, dynamic>))
          .toList();
      categories = List<String>.from(
        data['categories'] ??
            ['Storage', 'Memory', 'Peripherals', 'Networking', 'Components'],
      );
      addLog('Previous data loaded from local browser.');
    }
    notifyListeners();
  }

  Future<void> saveToStorage() async {
    await _storageService.saveData(
      settings: appSettings,
      inventory: inventory,
      salesHistory: salesHistory,
      categories: categories,
    );
    addLog('Database synced to local browser.');
    notifyListeners();
  }

  Future<void> clearStorage() async {
    await _storageService.clearData();
    inventory = [];
    salesHistory = [];
    currentCart = [];
    appSettings = AppSettings(storeName: 'EPC TechStock');
    categories = [
      'Storage',
      'Memory',
      'Peripherals',
      'Networking',
      'Components',
    ];
    addLog('Local saved data cleared.');
    notifyListeners();
  }

  void addLog(String message) {
    activityLog.insert(0, message);
    if (activityLog.length > 5) {
      activityLog.removeLast();
    }
    notifyListeners();
  }

  void updateStoreName(String name) {
    appSettings.storeName = name;
    notifyListeners();
  }

  // Product operations
  void addProduct(Product product) {
    final newId = inventory.isNotEmpty
        ? inventory.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1
        : 1;
    inventory.add(product.copyWith(id: newId));
    addLog('Added ${product.name}');
    notifyListeners();
  }

  void updateProduct(Product product) {
    final index = inventory.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      inventory[index] = product;
      addLog('Updated ${product.name}');
      notifyListeners();
    }
  }

  void deleteProduct(int id) {
    final product = inventory.firstWhere((p) => p.id == id);
    inventory.removeWhere((p) => p.id == id);
    addLog('Removed ${product.name}');
    notifyListeners();
  }

  // Category operations
  void addCategory(String name) {
    if (!categories.contains(name)) {
      categories.add(name);
      addLog('Added new category: $name');
      notifyListeners();
    }
  }

  void deleteCategory(String name) {
    if (!inventory.any((p) => p.category == name)) {
      categories.remove(name);
      addLog('Removed category: $name');
      notifyListeners();
    }
  }

  void clearCategories() {
    categories = [
      'Storage',
      'Memory',
      'Peripherals',
      'Networking',
      'Components',
    ];
    addLog('Categories reset to default');
    notifyListeners();
  }

  void clearAllCategories() {
    categories = [];
    addLog('All categories cleared');
    notifyListeners();
  }

  // Cart operations
  void addToCart(Product product, int qty) {
    final existingIndex = currentCart.indexWhere(
      (item) => item.id == product.id,
    );
    if (existingIndex != -1) {
      currentCart[existingIndex] = CartItem(
        id: product.id,
        name: product.name,
        price: product.price,
        qty: currentCart[existingIndex].qty + qty,
      );
    } else {
      currentCart.add(
        CartItem(
          id: product.id,
          name: product.name,
          price: product.price,
          qty: qty,
        ),
      );
    }
    notifyListeners();
  }

  void removeFromCart(int index) {
    currentCart.removeAt(index);
    notifyListeners();
  }

  void processCheckout() {
    if (currentCart.isEmpty) return;

    final now = DateTime.now();
    final timeString =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final List<String> itemsProcessed = [];
    for (final cartItem in currentCart) {
      final productIndex = inventory.indexWhere((p) => p.id == cartItem.id);
      if (productIndex != -1) {
        final product = inventory[productIndex];
        inventory[productIndex] = product.copyWith(
          stock: product.stock - cartItem.qty,
        );
        final totalPrice = product.price * cartItem.qty;
        salesHistory.add(
          SaleRecord(
            name: product.name,
            qty: cartItem.qty,
            totalPrice: totalPrice,
            time: timeString,
          ),
        );
        itemsProcessed.add('${cartItem.qty}x ${product.name}');
      }
    }

    addLog('Sold: ${itemsProcessed.join(', ')}');
    currentCart = [];
    notifyListeners();
  }

  // Computed values
  int get totalProducts => inventory.length;

  double get totalAssetValue =>
      inventory.fold(0.0, (sum, p) => sum + (p.price * p.stock));

  double get totalRevenue =>
      salesHistory.fold(0.0, (sum, s) => sum + s.totalPrice);

  List<Product> get lowStockItems =>
      inventory.where((p) => p.stock > 0 && p.stock <= 5).toList();

  List<Product> get outOfStockItems =>
      inventory.where((p) => p.stock == 0).toList();

  List<Product> get actionItems =>
      inventory.where((p) => p.stock <= 5).toList();

  Map<String, double> get categoryCapital {
    final Map<String, double> capitals = {};
    for (final product in inventory) {
      final value = product.price * product.stock;
      capitals[product.category] = (capitals[product.category] ?? 0) + value;
    }
    return capitals;
  }
}
