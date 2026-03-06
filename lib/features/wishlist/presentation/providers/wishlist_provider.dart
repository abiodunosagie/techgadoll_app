import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../products/data/models/product_model.dart';

const _wishlistKey = 'wishlist_items';

class WishlistState {
  final List<ProductModel> items;

  const WishlistState({this.items = const []});

  bool contains(int productId) {
    return items.any((item) => item.id == productId);
  }

  int get count => items.length;
}

class WishlistNotifier extends StateNotifier<WishlistState> {
  WishlistNotifier() : super(const WishlistState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_wishlistKey);
    if (raw == null) return;

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final items = list
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
      state = WishlistState(items: items);
    } catch (_) {
      // Corrupted data, start fresh
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.items.map((e) => e.toJson()).toList());
    await prefs.setString(_wishlistKey, json);
  }

  void toggle(ProductModel product) {
    if (state.contains(product.id)) {
      state = WishlistState(
        items: state.items.where((item) => item.id != product.id).toList(),
      );
    } else {
      state = WishlistState(items: [...state.items, product]);
    }
    _save();
  }

  void remove(int productId) {
    state = WishlistState(
      items: state.items.where((item) => item.id != productId).toList(),
    );
    _save();
  }

  void clear() {
    state = const WishlistState();
    _save();
  }
}

final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, WishlistState>((ref) {
  return WishlistNotifier();
});
