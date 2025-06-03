import 'package:flutter/material.dart';
import 'package:cityvoice/services/api_service.dart';
import 'package:cityvoice/models/product.dart';


/// Экран магазина вознаграждений, где пользователи могут покупать товары за накопленные монеты.
class RewardsShopScreen extends StatefulWidget {
  const RewardsShopScreen({super.key});

  @override
  State<RewardsShopScreen> createState() => _RewardsShopScreenState();
}

class _RewardsShopScreenState extends State<RewardsShopScreen> {
  final ApiService _api = ApiService();
  List<Product> _products = [];
  int _balance = 0;
  String _selectedCategory = 'Все';

  @override
  void initState() {
    super.initState();
    _loadData(); // загружаем данные при старте экрана
  }

  /// Загружает список товаров и баланс пользователя
  Future<void> _loadData() async {
    final products = await _api.getProducts();
    final balance = await _api.getBalance();
    setState(() {
      _products = products;
      _balance = balance;
    });
  }

  /// Покупка товара: если достаточно монет — отправляем запрос
  void _buy(Product product) async {
    final success = await _api.purchaseProduct(product.id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Покупка совершена!')),
      );
      _loadData(); // обновляем данные после покупки
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Недостаточно монет')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Формируем список категорий: "Все" + уникальные категории товаров
    final categories = ['Все', ..._products.map((e) => e.category).toSet()];

    // Фильтруем товары в зависимости от выбранной категории
    final filtered = _selectedCategory == 'Все'
        ? _products
        : _products.where((p) => p.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Магазин')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Баланс пользователя
            Text('Баланс: $_balance монет', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),

            // Поиск (пока не используется для фильтрации)
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Поиск',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}), // пока заглушка
            ),
            const SizedBox(height: 12),

            // Выбор категории
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: categories.map((cat) {
                  final selected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Сетка товаров
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
                children: filtered.map((product) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Фото товара
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                            child: product.imageUrl != null
                                ? Image.network(
                                    product.imageUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                : const Placeholder(), // если фото нет
                          ),
                        ),
                        // Название, цена и кнопка покупки
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('${product.price} монет'),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: IconButton(
                                  icon: const Icon(Icons.shopping_cart),
                                  onPressed: () => _buy(product),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
