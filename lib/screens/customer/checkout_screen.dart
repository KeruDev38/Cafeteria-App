import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/order_item.dart';
import '../../model/order.dart';
import '../../providers/order_provider.dart';
import '../../providers/shop_provider.dart';
import '../../providers/menu_provider.dart';
import 'confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<OrderItem> items;
  final double total;

  const CheckoutScreen({
    Key? key,
    required this.items,
    required this.total,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'card'; // 'card' or 'counter'
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen de Orden',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 24),
                    ...widget.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.quantity}x ${item.name}'),
                          Text('\$${item.total.toStringAsFixed(2)}'),
                        ],
                      ),
                    )),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${widget.total.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Payment method selection
            const Text(
              'Método de Pago',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Row(
                      children: [
                        Icon(Icons.credit_card, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Tarjeta de Crédito/Débito'),
                      ],
                    ),
                    value: 'card',
                    groupValue: _paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _paymentMethod = value!;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Row(
                      children: [
                        Icon(Icons.point_of_sale, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Pagar en Caja'),
                      ],
                    ),
                    value: 'counter',
                    groupValue: _paymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _paymentMethod = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Confirm button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _paymentMethod == 'card' 
                            ? 'Pagar \$${widget.total.toStringAsFixed(2)}'
                            : 'Confirmar Orden',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processOrder() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Reduce stock for all items
    final menuProvider = context.read<MenuProvider>();
    for (var item in widget.items) {
      menuProvider.reduceStock(item.id, item.quantity);
    }

    // Create the order
    final orderProvider = context.read<OrderProvider>();
    final shopProvider = context.read<ShopProvider>();
    
    final order = Order(
      id: orderProvider.getNextId(),
      customer: shopProvider.currentUser ?? 'Cliente Demo',
      items: widget.items,
      total: widget.total,
      status: OrderStatus.pending,
      timestamp: DateTime.now(),
    );

    orderProvider.addOrder(order);

    // Navigate to confirmation
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ConfirmationScreen(
          order: order,
          paymentMethod: _paymentMethod,
        ),
      ),
    );
  }
}