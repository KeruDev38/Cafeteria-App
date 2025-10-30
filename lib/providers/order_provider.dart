import 'package:flutter/foundation.dart';
import '../model/order.dart';
import '../model/order_item.dart';

class OrderProvider with ChangeNotifier {
  final List<Order> _orders = [
    Order(
      id: 1,
      customer: 'Ana García',
      items: [
        OrderItem(id: 1, name: 'Espresso', quantity: 2, price: 2.50),
      ],
      total: 5.00,
      status: OrderStatus.pending,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    Order(
      id: 2,
      customer: 'Carlos López',
      items: [
        OrderItem(id: 3, name: 'Latte', quantity: 1, price: 4.00),
        OrderItem(id: 5, name: 'Croissant', quantity: 1, price: 2.00),
      ],
      total: 6.00,
      status: OrderStatus.called,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];

  List<Order> get orders => _orders;

  List<Order> get activeOrders {
    return _orders.where((o) => 
      o.status == OrderStatus.pending || o.status == OrderStatus.called
    ).toList();
  }

  List<Order> getOrdersByCustomer(String customer) {
    return _orders.where((o) => o.customer == customer).toList();
  }

  Order? getOrderById(int id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }

  void addOrder(Order order) {
    _orders.add(order);
    notifyListeners();
  }

  void updateOrderStatus(int orderId, OrderStatus status) {
    final order = getOrderById(orderId);
    if (order != null) {
      order.status = status;
      notifyListeners();
    }
  }

  void callOrder(int orderId) {
    updateOrderStatus(orderId, OrderStatus.called);
  }

  void completeOrder(int orderId) {
    updateOrderStatus(orderId, OrderStatus.completed);
  }

  void cancelOrder(int orderId) {
    updateOrderStatus(orderId, OrderStatus.cancelled);
  }

  void deleteOrder(int orderId) {
    _orders.removeWhere((o) => o.id == orderId);
    notifyListeners();
  }

  int getNextId() {
    if (_orders.isEmpty) return 1;
    return _orders.map((o) => o.id).reduce((a, b) => a > b ? a : b) + 1;
  }
}
