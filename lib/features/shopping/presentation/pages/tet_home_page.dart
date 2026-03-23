import 'package:flutter/material.dart';
import 'package:tet_shop/features/shopping/models/price_entry.dart';
import 'package:tet_shop/features/shopping/models/shopping_item.dart';

class TetHomePage extends StatefulWidget {
  const TetHomePage({super.key});

  @override
  State<TetHomePage> createState() => _TetHomePageState();
}

class _TetHomePageState extends State<TetHomePage> {
  final List<String> _markets = <String>['Chợ Đồng Xuân', 'Vinmart', 'Chợ Hôm', 'Big C'];
  final List<String> _categories = <String>['Thực phẩm', 'Bánh kẹo', 'Trang trí', 'Đồ uống'];

  final TextEditingController _compareItemController = TextEditingController();
  final TextEditingController _compareMarketController = TextEditingController();
  final TextEditingController _comparePriceController = TextEditingController();

  int _tabIndex = 0;
  String _selectedMarketFilter = 'Tất cả';
  final List<ShoppingItem> _items = <ShoppingItem>[
    ShoppingItem(
      id: 'seed-1',
      name: 'Bánh chưng',
      quantity: 2,
      unit: 'cái',
      estimatedPrice: 180000,
      market: 'Chợ Đồng Xuân',
      category: 'Thực phẩm',
    ),
    ShoppingItem(
      id: 'seed-2',
      name: 'Mứt Tết',
      quantity: 2,
      unit: 'hộp',
      estimatedPrice: 120000,
      market: 'Vinmart',
      category: 'Bánh kẹo',
    ),
  ];
  final Map<String, List<PriceEntry>> _comparison = <String, List<PriceEntry>>{};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _compareItemController.dispose();
    _compareMarketController.dispose();
    _comparePriceController.dispose();
    super.dispose();
  }

  void _saveData() {}

  double get _totalEstimated => _items.fold(0, (double sum, ShoppingItem i) => sum + i.total);
  double get _totalSpent =>
      _items.where((ShoppingItem i) => i.isBought).fold(0, (double sum, ShoppingItem i) => sum + i.total);
  double get _remaining => _totalEstimated - _totalSpent;

  String _formatMoney(double value) {
    final String digits = value.round().toString();
    final RegExp regExp = RegExp(r'\B(?=(\d{3})+(?!\d))');
    final String pretty = digits.replaceAllMapped(regExp, (Match m) => '.');
    return '$pretty đ';
  }

  List<ShoppingItem> get _filteredItems {
    if (_selectedMarketFilter == 'Tất cả') return _items;
    return _items.where((ShoppingItem e) => e.market == _selectedMarketFilter).toList();
  }

  Future<void> _showItemDialog({ShoppingItem? editing}) async {
    final TextEditingController nameCtrl = TextEditingController(text: editing?.name ?? '');
    final TextEditingController qtyCtrl = TextEditingController(text: editing?.quantity.toString() ?? '1');
    final TextEditingController unitCtrl = TextEditingController(text: editing?.unit ?? 'cái');
    final TextEditingController priceCtrl =
        TextEditingController(text: editing?.estimatedPrice.toStringAsFixed(0) ?? '');
    String market = editing?.market ?? _markets.first;
    String category = editing?.category ?? _categories.first;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setDialogState) {
            return AlertDialog(
              title: Text(editing == null ? 'Thêm món mới' : 'Sửa món'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Tên món'),
                    ),
                    TextField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Số lượng'),
                    ),
                    TextField(
                      controller: unitCtrl,
                      decoration: const InputDecoration(labelText: 'Đơn vị'),
                    ),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Giá dự kiến'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: market,
                      decoration: const InputDecoration(labelText: 'Nơi mua'),
                      items: _markets
                          .map((String e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setDialogState(() => market = value);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Danh mục'),
                      items: _categories
                          .map((String e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setDialogState(() => category = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () {
                    final String name = nameCtrl.text.trim();
                    final double qty = double.tryParse(qtyCtrl.text.trim()) ?? 0;
                    final double price = double.tryParse(priceCtrl.text.trim()) ?? 0;
                    if (name.isEmpty || qty <= 0) return;

                    setState(() {
                      if (editing == null) {
                        _items.add(
                          ShoppingItem(
                            id: DateTime.now().microsecondsSinceEpoch.toString(),
                            name: name,
                            quantity: qty,
                            unit: unitCtrl.text.trim().isEmpty ? 'cái' : unitCtrl.text.trim(),
                            estimatedPrice: price,
                            market: market,
                            category: category,
                          ),
                        );
                      } else {
                        final int idx = _items.indexWhere((ShoppingItem e) => e.id == editing.id);
                        if (idx != -1) {
                          _items[idx] = ShoppingItem(
                            id: editing.id,
                            name: name,
                            quantity: qty,
                            unit: unitCtrl.text.trim().isEmpty ? 'cái' : unitCtrl.text.trim(),
                            estimatedPrice: price,
                            market: market,
                            category: category,
                            isBought: editing.isBought,
                          );
                        }
                      }
                    });
                    _saveData();
                    Navigator.pop(context);
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addComparisonEntry() {
    final String itemName = _compareItemController.text.trim();
    final String market = _compareMarketController.text.trim();
    final double? price = double.tryParse(_comparePriceController.text.trim());
    if (itemName.isEmpty || market.isEmpty || price == null || price <= 0) {
      return;
    }

    setState(() {
      _comparison.putIfAbsent(itemName, () => <PriceEntry>[]);
      _comparison[itemName]!.removeWhere((PriceEntry e) => e.market.toLowerCase() == market.toLowerCase());
      _comparison[itemName]!.add(PriceEntry(market: market, price: price));
      _comparison[itemName]!.sort((PriceEntry a, PriceEntry b) => a.price.compareTo(b.price));
    });
    _saveData();
    _compareMarketController.clear();
    _comparePriceController.clear();
  }

  void _assignCheapestToList() {
    final String itemName = _compareItemController.text.trim();
    final List<PriceEntry>? entries = _comparison[itemName];
    if (itemName.isEmpty || entries == null || entries.isEmpty) return;
    final PriceEntry cheapest = entries.first;
    setState(() {
      for (final ShoppingItem item in _items) {
        if (item.name.toLowerCase() == itemName.toLowerCase() && !item.isBought) {
          final int idx = _items.indexOf(item);
          _items[idx] = ShoppingItem(
            id: item.id,
            name: item.name,
            quantity: item.quantity,
            unit: item.unit,
            estimatedPrice: cheapest.price,
            market: cheapest.market,
            category: item.category,
            isBought: item.isBought,
          );
        }
      }
    });
    _saveData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã gán nơi rẻ nhất (${cheapest.market}) cho "$itemName"')),
    );
  }

  Widget _buildListTab() {
    final List<ShoppingItem> items = _filteredItems;
    final int remainingInFilter = items.where((ShoppingItem e) => !e.isBought).length;

    return Column(
      children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: <String>['Tất cả', ..._markets].map((String market) {
              final bool selected = _selectedMarketFilter == market;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(market),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedMarketFilter = market),
                ),
              );
            }).toList(),
          ),
        ),
        if (_selectedMarketFilter != 'Tất cả' && remainingInFilter > 0)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Còn $remainingInFilter món chưa mua ở $_selectedMarketFilter'),
          ),
        Expanded(
          child: items.isEmpty
              ? const Center(child: Text('Chưa có món nào. Nhấn + để thêm.'))
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, int index) {
                    final ShoppingItem item = items[index];
                    return ListTile(
                      leading: Checkbox(
                        value: item.isBought,
                        onChanged: (bool? value) {
                          setState(() {
                            item.isBought = value ?? false;
                          });
                          _saveData();
                        },
                      ),
                      title: Text(
                        '${item.name} x ${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 1)} ${item.unit}',
                        style: TextStyle(
                          decoration: item.isBought ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Text('${item.market} • ${item.category}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(_formatMoney(item.total)),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showItemDialog(editing: item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              setState(() {
                                _items.removeWhere((ShoppingItem e) => e.id == item.id);
                              });
                              _saveData();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildComparisonTab() {
    final String itemName = _compareItemController.text.trim();
    final List<PriceEntry> entries = _comparison[itemName] ?? <PriceEntry>[];
    final double? minPrice = entries.isEmpty ? null : entries.first.price;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _compareItemController,
            decoration: const InputDecoration(
              labelText: 'Mặt hàng so sánh (vd: Bưởi 5 roi)',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _compareMarketController,
                  decoration: const InputDecoration(
                    labelText: 'Nơi bán',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _comparePriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Giá',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _addComparisonEntry,
            icon: const Icon(Icons.add),
            label: const Text('Thêm nơi so sánh'),
          ),
          const SizedBox(height: 16),
          if (itemName.isNotEmpty) ...<Widget>[
            Text('Giá theo từng nơi', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              const Text('Chưa có dữ liệu so sánh cho mặt hàng này.')
            else
              ...entries.map((PriceEntry e) {
                final bool isCheapest = minPrice != null && e.price == minPrice;
                return Card(
                  color: isCheapest ? Colors.green.shade50 : null,
                  child: ListTile(
                    title: Text(e.market),
                    subtitle: Text(isCheapest ? 'Rẻ nhất' : ''),
                    trailing: Text(
                      _formatMoney(e.price),
                      style: TextStyle(
                        color: isCheapest ? Colors.green.shade700 : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: entries.isEmpty ? null : _assignCheapestToList,
              child: const Text('Gán nơi rẻ nhất vào danh sách'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    final int boughtCount = _items.where((ShoppingItem e) => e.isBought).length;
    final int totalCount = _items.length;
    final double progress = totalCount == 0 ? 0 : boughtCount / totalCount;
    final Map<String, double> byCategory = <String, double>{};

    for (final ShoppingItem item in _items) {
      byCategory[item.category] = (byCategory[item.category] ?? 0) + item.total;
    }

    final List<ShoppingItem> pending = _items.where((ShoppingItem e) => !e.isBought).toList();

    Widget metricCard(String title, double value, Color color) {
      return Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 6),
                Text(
                  _formatMoney(value),
                  style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              metricCard('Dự kiến', _totalEstimated, Colors.orange.shade700),
              metricCard('Đã chi', _totalSpent, Colors.green.shade700),
              metricCard('Còn lại', _remaining, Colors.blue.shade700),
            ],
          ),
          const SizedBox(height: 14),
          Text('Tiến độ mua sắm: $boughtCount/$totalCount món (${(progress * 100).round()}%)'),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 16),
          Text('Chi theo danh mục', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...byCategory.entries.map(
            (MapEntry<String, double> e) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(e.key),
              trailing: Text(_formatMoney(e.value)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Món chưa mua', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (pending.isEmpty)
            const Text('Đã mua xong hết rồi!')
          else
            ...pending.map(
              (ShoppingItem e) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(e.name),
                subtitle: Text('Cần mua ở ${e.market}'),
                trailing: Text(_formatMoney(e.total)),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = <Widget>[
      _buildListTab(),
      _buildComparisonTab(),
      _buildSummaryTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đi chợ Tết thông minh'),
      ),
      body: tabs[_tabIndex],
      floatingActionButton: _tabIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showItemDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Thêm món'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (int value) => setState(() => _tabIndex = value),
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Danh sách'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Danh sách giá'),
          NavigationDestination(icon: Icon(Icons.savings), label: 'Tổng kết'),
        ],
      ),
    );
  }SS
}
