class Product {
  int id;
  String name;
  String category;
  double price;
  int stock;
  String? img;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.img,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      img: json['img'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'img': img,
    };
  }

  Product copyWith({
    int? id,
    String? name,
    String? category,
    double? price,
    int? stock,
    String? img,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      img: img ?? this.img,
    );
  }
}

class SaleRecord {
  String name;
  int qty;
  double totalPrice;
  String time;

  SaleRecord({
    required this.name,
    required this.qty,
    required this.totalPrice,
    required this.time,
  });

  factory SaleRecord.fromJson(Map<String, dynamic> json) {
    return SaleRecord(
      name: json['name'] as String,
      qty: json['qty'] as int,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      time: json['time'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'qty': qty, 'totalPrice': totalPrice, 'time': time};
  }
}

class CartItem {
  int id;
  String name;
  double price;
  int qty;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.qty,
  });
}

class AppSettings {
  String storeName;

  AppSettings({required this.storeName});

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      storeName: json['storeName'] as String? ?? 'EPC TechStock',
    );
  }

  Map<String, dynamic> toJson() {
    return {'storeName': storeName};
  }
}
