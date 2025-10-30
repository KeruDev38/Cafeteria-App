import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/menu_provider.dart';
import '../../model/product.dart';
import '../../model/order_item.dart';
import 'checkout_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final Map<int, int> _cart = {};
  String? _selectedCategory;
  bool _isCartExpanded = false;
  bool _showCartContent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hacer Pedido'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
      body: Consumer<MenuProvider>(
        builder: (context, menuProvider, child) {
          final categories = menuProvider.categories;
          final displayCategory = _selectedCategory ??
              (categories.isNotEmpty ? categories.first : null);
          final products = displayCategory != null ? menuProvider.getProductsByCategory(displayCategory) : [];

          return Stack(
            children: [
              // --- MAIN CONTENT (MENU + GRID) ---
              Positioned.fill(
                child: Column(
                  children: [
                    // Category tabs
                    Container(
                      height: 60,
                      color: Colors.grey.shade100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected = category == displayCategory;
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                              selectedColor: Colors.green.shade600,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Product grid
                    Expanded(
                      child: products.isEmpty
                          ? Center(
                              child: Text(
                                'No hay productos en esta categoría',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                return _buildProductCard(products[index]);
                              },
                            ),
                    ),
                  ],
                ),
              ),

              // --- CART SIDEBAR ---
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: _isCartExpanded ? 300 : 60,
                  decoration: BoxDecoration(
                    color: _isCartExpanded ? Colors.white : Colors.transparent,
                    boxShadow: _isCartExpanded ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(-2, 0),
                      ),
                    ] : [],
                  ),
                  child: _isCartExpanded ? _buildCartSidebar(menuProvider) : const SizedBox.shrink(),
                ),
              ),
              // --- FLOATING CART BUTTON (when minimized) ---
              if (!_isCartExpanded)
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isCartExpanded = true;
                      });
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (mounted) {
                          setState(() {
                            _showCartContent = true;
                          });
                        }
                      });
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Icon(Icons.shopping_cart, color: Colors.white, size: 28),
                          ),
                          if (_cart.values.fold<int>(0, (sum, qty) => sum + qty) > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 20,
                                  minHeight: 20,
                                ),
                                child: Center(
                                  child: Text(
                                    '${_cart.values.fold<int>(0, (sum, qty) => sum + qty)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final quantity = _cart[product.id] ?? 0;
    final outOfStock = product.stock == 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Icon(
                Icons.coffee,
                size: 64,
                color: outOfStock ? Colors.grey : Colors.green.shade600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: outOfStock ? Colors.grey : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            outOfStock ? Colors.grey : Colors.green.shade700,
                      ),
                    ),
                    Text(
                      'Stock: ${product.stock}',
                      style: TextStyle(
                        fontSize: 12,
                        color: outOfStock ? Colors.red : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (outOfStock)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Agotado',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else if (quantity == 0)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _addToCart(product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Agregar'),
                    ),
                  )
                else
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _decrementQuantity(product.id),
                        icon: const Icon(Icons.remove_circle),
                        color: Colors.red,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: quantity < product.stock
                            ? () => _incrementQuantity(product.id)
                            : null,
                        icon: const Icon(Icons.add_circle),
                        color: Colors.green,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSidebar(MenuProvider menuProvider) {
    final cartItems = _cart.entries
        .where((entry) => entry.value > 0)
        .map((entry) {
          final product = menuProvider.getProductById(entry.key);
          if (product == null) return null;
          return OrderItem(
            id: product.id,
            name: product.name,
            quantity: entry.value,
            price: product.price,
          );
        })
        .whereType<OrderItem>()
        .toList();

    final total = cartItems.fold<double>(0, (sum, item) => sum + item.total);

    return Column(
      children: [
        if (_showCartContent)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade600,
            child: Row(
              children: [
                const Icon(Icons.shopping_cart, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Mi Orden',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showCartContent = false;
                      _isCartExpanded = false;
                    });
                  },
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  tooltip: 'Minimizar carrito',
                ),
              ],
            ),
          ),
        if (_showCartContent)
          Expanded(
            child: cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Carrito vacío',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _removeFromCart(item.id),
                                    icon: const Icon(Icons.close, size: 20),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      '${item.quantity}x \$${item.price.toStringAsFixed(2)}'),
                                  Text(
                                    '\$${item.total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        if (_showCartContent)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: cartItems.isEmpty
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutScreen(
                                  items: cartItems,
                                  total: total,
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: const Text(
                      'Proceder al Pago',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _addToCart(Product product) {
    if (product.stock > 0) {
      setState(() {
        _cart[product.id] = 1;
      });
    }
  }

  void _incrementQuantity(int productId) {
    setState(() {
      _cart[productId] = (_cart[productId] ?? 0) + 1;
    });
  }

  void _decrementQuantity(int productId) {
    setState(() {
      final current = _cart[productId] ?? 0;
      if (current > 1) {
        _cart[productId] = current - 1;
      } else {
        _cart.remove(productId);
      }
    });
  }

  void _removeFromCart(int productId) {
    setState(() {
      _cart.remove(productId);
    });
  }
}