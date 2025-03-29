import 'package:flutter/material.dart';
import '../models/cart_items.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  
  void updateCustomization(String itemName, String customization) {
    final index = _items.indexWhere((item) => item.name == itemName);
    if (index >= 0) {
      _items[index].customization = customization;
      notifyListeners();
    }
  }
  double get totalPrice =>
      _items.fold(0.0, (total, item) => total + item.price * item.quantity);

  // Add item to cart or increase quantity if it already exists
  void addItem(CartItem newItem) {
    
    final existingItemIndex =
        _items.indexWhere((item) => item.name == newItem.name);

    if (existingItemIndex >= 0) {
      
      _items[existingItemIndex].quantity += newItem.quantity;
    } else {
     
      _items.add(newItem);
    }
    notifyListeners();
  }

  void overWriteItem(CartItem item) {
  final existingIndex =
      items.indexWhere((cartItem) => cartItem.name == item.name);

  if (existingIndex >= 0) {
    // Update the quantity directly for the existing item
    items[existingIndex].quantity = item.quantity;
  } else {
    // Add a new item to the cart
    items.add(item);
  }

  notifyListeners();
}

  // Decrease the quantity of an item or remove it if quantity is zero
  void decreaseQuantity(CartItem item) {
    final index = _items.indexWhere((i) => i.name == item.name);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Get the quantity of a specific item in the cart
  int getQuantity(CartItem item) {
    final index = _items.indexWhere((i) => i.name == item.name);
    return index >= 0 ? _items[index].quantity : 0;
  }

  // Remove a specific item from the cart
  void removeItem(CartItem item) {
    _items.removeWhere((i) => i.name == item.name);
    notifyListeners();
  }

  // Clear the entire cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
