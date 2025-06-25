//unused


import 'package:flutter/foundation.dart';
import 'package:baru/model/produk.dart';

// Model untuk item di keranjang, dipindahkan ke sini agar bisa diakses global
class CartItem {
  final int id;
  final String imageUrl;
  final String name;
  final int price;
  int quantity;

  CartItem({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  int get total => price * quantity;
}

class CartService with ChangeNotifier {
  final Map<int, CartItem> _items = {};

  Map<int, CartItem> get items {
    return {..._items};
  }

  List<CartItem> get cartItemsList => _items.values.toList();

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0; // Tetap double untuk kemudahan kalkulasi di UI
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(ProdukResponModel product, int quantity) {
    if (product.idProduk == null) return; // Jangan tambahkan jika produk tidak punya ID

    if (_items.containsKey(product.idProduk)) {
      // hanya update kuantitas
      _items.update(
        product.idProduk!,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          name: existingCartItem.name,
          price: existingCartItem.price,
          imageUrl: existingCartItem.imageUrl,
          quantity: existingCartItem.quantity + quantity,
        ),
      );
    } else {
      // tambah item baru
      _items.putIfAbsent(
        product.idProduk!,
        () => CartItem(
          id: product.idProduk!,
          name: product.namaProduk ?? 'No Name',
          price: product.hargaProduk ?? 0,
          imageUrl: product.fotoProduk ?? '',
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int newQuantity) {
    if (!_items.containsKey(productId)) return;
    if (newQuantity > 0) {
      _items.update(
        productId,
        (existing) => CartItem(
            id: existing.id,
            imageUrl: existing.imageUrl,
            name: existing.name,
            price: existing.price,
            quantity: newQuantity),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
