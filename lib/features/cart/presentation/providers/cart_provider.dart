import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../products/data/models/product_model.dart';

const _cartKey = 'cart_items';

class CartItem {
  final ProductModel product;
  final int quantity;

  const CartItem({required this.product, this.quantity = 1});

  CartItem copyWith({int? quantity}) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
  }

  double get total {
    final unitPrice = product.discountedPrice ?? product.price ?? 0;
    return unitPrice * quantity;
  }

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
        quantity: json['quantity'] as int? ?? 1,
      );
}

class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.total);

  bool containsProduct(int productId) {
    return items.any((item) => item.product.id == productId);
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cartKey);
    if (raw == null) return;

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final items = list
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();
      state = CartState(items: items);
    } catch (_) {
      // Corrupted data, start fresh
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.items.map((e) => e.toJson()).toList());
    await prefs.setString(_cartKey, json);
  }

  void addToCart(ProductModel product) {
    final existingIndex = state.items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      final updated = List<CartItem>.from(state.items);
      updated[existingIndex] = updated[existingIndex].copyWith(
        quantity: updated[existingIndex].quantity + 1,
      );
      state = CartState(items: updated);
    } else {
      state = CartState(items: [...state.items, CartItem(product: product)]);
    }
    _save();
  }

  void removeFromCart(int productId) {
    state = CartState(
      items: state.items.where((item) => item.product.id != productId).toList(),
    );
    _save();
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final updated = List<CartItem>.from(state.items);
    final index = updated.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      updated[index] = updated[index].copyWith(quantity: quantity);
      state = CartState(items: updated);
    }
    _save();
  }

  void clearCart() {
    state = const CartState();
    _save();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
