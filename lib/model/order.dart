import 'package:flutter/material.dart';
import '../model/order_item.dart';

enum OrderStatus { pending, called, completed, cancelled }

class Order {
  final int id;
  final String customer;
  final List<OrderItem> items;
  final double total;
  OrderStatus status;
  final DateTime timestamp;

  Order({
    required this.id,
    required this.customer,
    required this.items,
    required this.total,
    required this.status,
    required this.timestamp,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.called:
        return 'Llamado';
      case OrderStatus.completed:
        return 'Completado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.yellow.shade700;
      case OrderStatus.called:
        return Colors.blue.shade700;
      case OrderStatus.completed:
        return Colors.green.shade700;
      case OrderStatus.cancelled:
        return Colors.red.shade700;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer': customer,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'status': status.index,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customer: json['customer'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      total: json['total'].toDouble(),
      status: OrderStatus.values[json['status']],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
