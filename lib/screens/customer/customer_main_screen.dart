import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/shop_provider.dart';
import '../login_screen.dart';
import 'customer_orders_screen.dart';
import 'order_screen.dart';

class CustomerMainScreen extends StatelessWidget {
  const CustomerMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        title: Consumer<ShopProvider>(
          builder: (context, shopProvider, child) {
            return Row(
              children: [
                const Icon(Icons.coffee),
                const SizedBox(width: 8),
                Expanded( // Expanded to prevent overflow
                  child: Text(
                    'Bienvenido, ${shopProvider.currentUser}',
                    maxLines: 1, // only one line
                    overflow: TextOverflow.ellipsis, // adds "..." if too long
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<ShopProvider>().logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey.shade100, Colors.white],
          ),
        ),
        child: Consumer<ShopProvider>(
          builder: (context, shopProvider, child) {
            return Column(
              children: [
                if (!shopProvider.isOpen)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.red.shade100,
                    child: Row(
                      children: [
                        Icon(Icons.info, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'La tienda está cerrada temporalmente',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildMenuCard(
                          context,
                          title: 'Mis Órdenes',
                          icon: Icons.shopping_cart,
                          color: Colors.teal.shade600,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CustomerOrdersScreen(),
                              ),
                            );
                          },
                        ),
                        _buildMenuCard(
                          context,
                          title: 'Ordenar',
                          icon: Icons.add_shopping_cart,
                          color: Colors.green.shade600,
                          onTap: shopProvider.isOpen
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const OrderScreen(),
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuCard( // Pasar a widget reutilizable
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: color),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
