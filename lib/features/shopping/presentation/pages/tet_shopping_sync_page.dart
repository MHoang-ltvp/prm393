import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tet_shop/features/shopping/models/compare_draft_v2.dart';
import 'package:tet_shop/features/shopping/models/price_history_entry.dart';
import 'package:tet_shop/features/shopping/models/shopping_collection.dart';
import 'package:tet_shop/features/shopping/models/shopping_item.dart';

class TetShoppingSyncPage extends StatefulWidget {
  const TetShoppingSyncPage({super.key});

  @override
  State<TetShoppingSyncPage> createState() => _TetShoppingSyncPageState();
}

class _TetShoppingSyncPageState extends State<TetShoppingSyncPage> {
  final Random _random = Random();

  final List<String> _categories = <String>[
    'Thực phẩm',
    'Bánh kẹo',
    'Hoa quả',
    'Trang trí',
    'Quần áo',
    'Khác',
  ];

  final List<String> _markets = <String>[
    'Chợ Đồng Xuân',
    'Chợ Hôm',
    'Vinmart',
    'Siêu thị Big C',
    'Chợ gần nhà',
  ];

  final List<ShoppingCollection> _shoppingLists = <ShoppingCollection>[
    ShoppingCollection(id: 'l1', name: 'Sắm đồ cúng Tết', items: <ShoppingItem>[
      ShoppingItem(
        id: 'i1',
        name: 'Bánh chưng',
        quantity: 2,
        unit: 'cái',
        estimatedPrice: 75000,
        market: 'Chợ Đồng Xuân',
        category: 'Thực phẩm',
      ),
    ]),
  ];

  final List<PriceHistoryEntry> _priceHistory = <PriceHistoryEntry>[
    PriceHistoryEntry(id: 'h1', name: 'Thịt gà', unit: 'kg', market: 'Chợ Hôm', price: 120000),
    PriceHistoryEntry(id: 'h2', name: 'Thịt gà', unit: 'kg', market: 'Vinmart', price: 155000),
    PriceHistoryEntry(id: 'h3', name: 'Thịt gà', unit: 'kg', market: 'Chợ Đồng Xuân', price: 115000),
    PriceHistoryEntry(id: 'h4', name: 'Thịt lợn', unit: 'kg', market: 'Chợ gần nhà', price: 140000),
    PriceHistoryEntry(id: 'h5', name: 'Thịt lợn', unit: 'kg', market: 'Siêu thị Big C', price: 135000),
    PriceHistoryEntry(id: 'h6', name: 'Bánh chưng', unit: 'cái', market: 'Chợ Đồng Xuân', price: 75000),
    PriceHistoryEntry(id: 'h7', name: 'Mứt tết', unit: 'hộp', market: 'Siêu thị Big C', price: 120000),
    PriceHistoryEntry(id: 'h8', name: 'Mứt tết', unit: 'hộp', market: 'Chợ Hôm', price: 100000),
  ];

  final TextEditingController _newMarketCtrl = TextEditingController();
  final TextEditingController _newListCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _qtyCtrl = TextEditingController(text: '1');
  final TextEditingController _unitCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _compareItemCtrl = TextEditingController();
  final TextEditingController _compareUnitCtrl = TextEditingController();
  final TextEditingController _historySearchCtrl = TextEditingController();
  final TextEditingController _editPriceCtrl = TextEditingController();
  final TextEditingController _editUnitCtrl = TextEditingController();

  String _activeListId = 'l1';
  String _activeTab = 'list';
  String _filterMarket = 'Tất cả';
  String _marketForm = 'Chợ Đồng Xuân';
  String _categoryForm = 'Thực phẩm';
  bool _showAddForm = false;
  bool _showConfigManager = false;
  bool _showCompareInput = false;
  bool _isTypingName = false;
  String _selectedItemName = '';
  String? _editingHistoryId;
  String _editMarket = 'Chợ Đồng Xuân';
  final Set<String> _expandedHistoryNames = <String>{};
  List<CompareDraftV2> _compareDrafts = <CompareDraftV2>[CompareDraftV2(market: 'Chợ Đồng Xuân')];

  @override
  void dispose() {
    _newMarketCtrl.dispose();
    _newListCtrl.dispose();
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _unitCtrl.dispose();
    _priceCtrl.dispose();
    _compareItemCtrl.dispose();
    _compareUnitCtrl.dispose();
    _historySearchCtrl.dispose();
    _editPriceCtrl.dispose();
    _editUnitCtrl.dispose();
    super.dispose();
  }

  String _generateId() {
    return DateTime.now().microsecondsSinceEpoch.toRadixString(36) +
        _random.nextInt(99999).toRadixString(36);
  }

  ShoppingCollection get _currentList {
    return _shoppingLists.firstWhere((ShoppingCollection e) => e.id == _activeListId);
  }

  List<ShoppingItem> get _currentItems => _currentList.items;
  List<ShoppingItem> get _allItems =>
      _shoppingLists.expand((ShoppingCollection l) => l.items).toList();

  List<ShoppingItem> get _filteredItems {
    return _currentItems
        .where((ShoppingItem i) => _filterMarket == 'Tất cả' || i.market == _filterMarket)
        .toList();
  }

  double get _totalEstimated => _currentItems.fold(0, (double s, ShoppingItem i) => s + i.total);

  double get _totalDone =>
      _currentItems.where((ShoppingItem i) => i.isBought).fold(0, (double s, ShoppingItem i) => s + i.total);

  double get _allTotalEstimated => _allItems.fold(0, (double s, ShoppingItem i) => s + i.total);
  double get _allTotalDone =>
      _allItems.where((ShoppingItem i) => i.isBought).fold(0, (double s, ShoppingItem i) => s + i.total);

  String _fmt(double n) {
    final String digits = n.round().toString();
    final RegExp regExp = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return '${digits.replaceAllMapped(regExp, (Match m) => '.')}đ';
  }

  List<String> get _nameSuggestions {
    final String keyword = _nameCtrl.text.trim().toLowerCase();
    if (keyword.isEmpty || _selectedItemName == _nameCtrl.text.trim()) return <String>[];
    final List<String> uniqueNames = _priceHistory.map((PriceHistoryEntry e) => e.name).toSet().toList();
    return uniqueNames.where((String n) => n.toLowerCase().contains(keyword)).take(5).toList();
  }

  _SmartSuggestion? get _smartSuggestion {
    final String currentName = _nameCtrl.text.trim();
    if (_selectedItemName.isEmpty || _selectedItemName != currentName) return null;
    final String currentUnit = _unitCtrl.text.trim().toLowerCase();
    final List<PriceHistoryEntry> matches = _priceHistory.where((PriceHistoryEntry h) {
      final bool sameName = h.name.toLowerCase() == currentName.toLowerCase();
      final bool sameUnit = currentUnit.isEmpty || h.unit.toLowerCase() == currentUnit;
      return sameName && sameUnit;
    }).toList();
    if (matches.isEmpty) return null;
    final List<double> prices = matches.map((PriceHistoryEntry e) => e.price).toList();
    matches.sort((PriceHistoryEntry a, PriceHistoryEntry b) => a.price.compareTo(b.price));
    return _SmartSuggestion(
      min: prices.reduce(min),
      max: prices.reduce(max),
      cheapestMarket: matches.first.market,
    );
  }

  List<PriceHistoryEntry> get _filteredHistory {
    final String keyword = _historySearchCtrl.text.trim().toLowerCase();
    if (keyword.isEmpty) return _priceHistory;
    return _priceHistory
        .where((PriceHistoryEntry h) =>
            h.name.toLowerCase().contains(keyword) || h.unit.toLowerCase().contains(keyword))
        .toList();
  }

  Map<String, List<PriceHistoryEntry>> get _historyGroups {
    final Map<String, List<PriceHistoryEntry>> groups = <String, List<PriceHistoryEntry>>{};
    for (final PriceHistoryEntry entry in _filteredHistory) {
      final String safeUnit = entry.unit.trim().isEmpty ? 'đơn vị' : entry.unit.trim();
      final String key = '${entry.name}__$safeUnit';
      groups.putIfAbsent(key, () => <PriceHistoryEntry>[]);
      groups[key]!.add(entry);
    }
    final List<String> sortedKeys = groups.keys.toList()..sort((String a, String b) => a.compareTo(b));
    return <String, List<PriceHistoryEntry>>{
      for (final String key in sortedKeys)
        key: groups[key]!..sort((PriceHistoryEntry a, PriceHistoryEntry b) => a.market.compareTo(b.market)),
    };
  }

  List<_MarketPriceRow> get _compareRows {
    final List<_MarketPriceRow> rows = _compareDrafts
        .map((CompareDraftV2 d) =>
            _MarketPriceRow(market: d.market, price: double.tryParse(d.price.trim()) ?? 0))
        .where(( _MarketPriceRow r) => r.price > 0)
        .toList();
    rows.sort(( _MarketPriceRow a,  _MarketPriceRow b) => a.price.compareTo(b.price));
    return rows;
  }

  void _addMarket() {
    final String market = _newMarketCtrl.text.trim();
    if (market.isEmpty || _markets.contains(market)) return;
    setState(() {
      _markets.add(market);
      _newMarketCtrl.clear();
    });
  }

  void _removeMarket(String market) {
    if (_markets.length <= 1) return;
    setState(() {
      _markets.remove(market);
      if (_filterMarket == market) _filterMarket = 'Tất cả';
      if (_marketForm == market) _marketForm = _markets.first;
      if (_editMarket == market) _editMarket = _markets.first;
      for (final CompareDraftV2 d in _compareDrafts) {
        if (d.market == market) d.market = _markets.first;
      }
    });
  }

  void _createList() {
    final String name = _newListCtrl.text.trim();
    if (name.isEmpty) return;
    final String id = 'l${_generateId()}';
    setState(() {
      _shoppingLists.add(ShoppingCollection(id: id, name: name, items: <ShoppingItem>[]));
      _activeListId = id;
      _filterMarket = 'Tất cả';
      _newListCtrl.clear();
    });
  }

  void _updatePriceHistory(String name, String unit, String market, double price) {
    final int idx =
        _priceHistory.indexWhere((PriceHistoryEntry e) => e.name == name && e.unit == unit && e.market == market);
    if (idx == -1) {
      _priceHistory.add(
        PriceHistoryEntry(id: 'h${_generateId()}', name: name, unit: unit, market: market, price: price),
      );
      return;
    }
    _priceHistory[idx] = _priceHistory[idx].copyWith(price: price);
  }

  void _addItem() {
    final String name = _nameCtrl.text.trim();
    final double qty = double.tryParse(_qtyCtrl.text.trim()) ?? 1;
    final double price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final String unit = _unitCtrl.text.trim().isEmpty ? 'đơn vị' : _unitCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _currentItems.add(
        ShoppingItem(
          id: 'i${_generateId()}',
          name: name,
          quantity: qty,
          unit: unit,
          estimatedPrice: price,
          market: _marketForm,
          category: _categoryForm,
        ),
      );
      _updatePriceHistory(name, unit, _marketForm, price);
      _nameCtrl.clear();
      _priceCtrl.clear();
      _selectedItemName = '';
      _showAddForm = false;
      _isTypingName = false;
    });
  }

  void _saveOnlyToHistory() {
    final String itemName = _compareItemCtrl.text.trim();
    final String unit = _compareUnitCtrl.text.trim().isEmpty ? 'đơn vị' : _compareUnitCtrl.text.trim();
    final List<_MarketPriceRow> rows = _compareRows;
    if (itemName.isEmpty || unit.isEmpty || rows.isEmpty) return;
    setState(() {
      for (final _MarketPriceRow r in rows) {
        _updatePriceHistory(itemName, unit, r.market, r.price);
      }
      _compareItemCtrl.clear();
      _compareUnitCtrl.clear();
      _compareDrafts = <CompareDraftV2>[CompareDraftV2(market: _markets.first)];
      _showCompareInput = false;
    });
  }

  void _selectSuggestion(String name) {
    setState(() {
      _nameCtrl.text = name;
      _selectedItemName = name;
      _isTypingName = false;
    });
  }

  void _applySmartDetails() {
    final _SmartSuggestion? data = _smartSuggestion;
    if (data == null) return;
    setState(() {
      _priceCtrl.text = data.min.round().toString();
      _marketForm = data.cheapestMarket;
    });
  }

  void _toggleItem(String id) {
    setState(() {
      final int idx = _currentItems.indexWhere((ShoppingItem i) => i.id == id);
      if (idx != -1) _currentItems[idx].isBought = !_currentItems[idx].isBought;
    });
  }

  void _removeItem(String id) {
    setState(() => _currentItems.removeWhere((ShoppingItem i) => i.id == id));
  }

  void _startEditHistory(PriceHistoryEntry e) {
    setState(() {
      _editingHistoryId = e.id;
      _editMarket = e.market;
      _editUnitCtrl.text = e.unit;
      _editPriceCtrl.text = e.price.round().toString();
    });
  }

  void _saveEditHistory(String id) {
    final double? price = double.tryParse(_editPriceCtrl.text.trim());
    if (price == null) return;
    setState(() {
      final int idx = _priceHistory.indexWhere((PriceHistoryEntry h) => h.id == id);
      if (idx != -1) {
        final String safeUnit = _editUnitCtrl.text.trim().isEmpty ? _priceHistory[idx].unit : _editUnitCtrl.text.trim();
        _priceHistory[idx] = _priceHistory[idx].copyWith(
          market: _editMarket,
          unit: safeUnit,
          price: price,
        );
      }
      _editingHistoryId = null;
      _editPriceCtrl.clear();
      _editUnitCtrl.clear();
    });
  }

  void _deleteHistoryItem(String id) {
    setState(() => _priceHistory.removeWhere((PriceHistoryEntry h) => h.id == id));
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFC0392B), Color(0xFFE74C3C), Color(0xFFF39C12)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      '🧧 CHỢ TẾT 2026',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _currentList.name,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _showConfigManager = !_showConfigManager),
                style: IconButton.styleFrom(
                  backgroundColor: _showConfigManager ? Colors.white : Colors.white24,
                ),
                icon: Icon(Icons.settings, color: _showConfigManager ? const Color(0xFFC0392B) : Colors.white),
              ),
            ],
          ),
          if (_showConfigManager) _configPanel(),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              _tabButton('list', 'Danh sách'),
              _tabButton('compare', 'So sánh giá'),
              _tabButton('summary', 'Tổng kết'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _configPanel() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Quản lý danh sách', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              ..._shoppingLists.map((ShoppingCollection e) {
                final bool active = _activeListId == e.id;
                return OutlinedButton(
                  onPressed: () => setState(() {
                    _activeListId = e.id;
                    _filterMarket = 'Tất cả';
                  }),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: active ? Colors.white : Colors.white24,
                    foregroundColor: active ? const Color(0xFFC0392B) : Colors.white,
                    side: BorderSide(color: active ? Colors.white : Colors.white24),
                  ),
                  child: Text(e.name),
                );
              }),
              OutlinedButton(
                onPressed: () async {
                  _newListCtrl.clear();
                  await showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Tạo danh sách mới'),
                        content: TextField(
                          controller: _newListCtrl,
                          decoration: const InputDecoration(hintText: 'Tên danh sách'),
                        ),
                        actions: <Widget>[
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                          FilledButton(
                            onPressed: () {
                              _createList();
                              Navigator.pop(context);
                            },
                            child: const Text('Tạo'),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('+ Mới'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Quản lý địa điểm', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _markets.map((String m) {
              return Chip(
                label: Text(m),
                onDeleted: _markets.length <= 1 ? null : () => _removeMarket(m),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _newMarketCtrl,
                  decoration: _inputStyle('Thêm chợ...'),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _addMarket,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFC0392B),
                ),
                child: const Text('Thêm'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String id, String label) {
    final bool active = _activeTab == id;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: OutlinedButton(
          onPressed: () => setState(() => _activeTab = id),
          style: OutlinedButton.styleFrom(
            backgroundColor: active ? Colors.white : Colors.white24,
            foregroundColor: active ? const Color(0xFFC0392B) : Colors.white,
            side: BorderSide(color: active ? Colors.white : Colors.white24),
          ),
          child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFFFFAF5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFF0D0B0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFC0392B)),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFF0D0B0)),
      ),
    );
  }

  Widget _statusBar() {
    final int progress = ((_totalDone / (_totalEstimated == 0 ? 1 : _totalEstimated)) * 100).round();
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('DỰ KIẾN', style: TextStyle(fontSize: 10, color: Color(0xFF999999), fontWeight: FontWeight.w700)),
              Text(_fmt(_totalEstimated), style: const TextStyle(fontSize: 16, color: Color(0xFFC0392B), fontWeight: FontWeight.w800)),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const Text('HOÀN THÀNH', style: TextStyle(fontSize: 10, color: Color(0xFF999999), fontWeight: FontWeight.w700)),
              Text('$progress%', style: const TextStyle(fontSize: 16, color: Color(0xFF27AE60), fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _listTab() {
    final int doneCount = _currentItems.where((ShoppingItem i) => i.isBought).length;
    final int progress = ((_totalDone / (_totalEstimated == 0 ? 1 : _totalEstimated)) * 100).round();
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(child: _summaryMetric('Dự kiến DS này', _fmt(_totalEstimated), const Color(0xFFC0392B))),
                  const SizedBox(width: 8),
                  Expanded(child: _summaryMetric('Đã mua DS này', '$doneCount/${_currentItems.length}', const Color(0xFF27AE60))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Tiến độ danh sách hiện tại', style: TextStyle(fontWeight: FontWeight.w700)),
                  Text('$progress%', style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: (progress / 100).clamp(0, 1),
                minHeight: 6,
                backgroundColor: const Color(0xFFEEEEEE),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF27AE60)),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <String>['Tất cả', ..._markets].map((String m) {
              final bool active = _filterMarket == m;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(m),
                  selected: active,
                  onSelected: (_) => setState(() => _filterMarket = m),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),
        if (_filteredItems.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Text('Chưa có món nào trong danh sách', style: TextStyle(color: Color(0xFFBBBBBB))),
          )
        else
          ..._filteredItems.map((ShoppingItem item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.isBought ? const Color(0xFFF8F8F8) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: item.isBought ? const Color(0xFFEEEEEE) : const Color(0xFFFBE8D0)),
              ),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () => _toggleItem(item.id),
                    icon: Icon(item.isBought ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: item.isBought ? const Color(0xFF27AE60) : const Color(0xFFCCCCCC)),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: item.isBought ? const Color(0xFFAAAAAA) : const Color(0xFF333333),
                            decoration: item.isBought ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        Text(
                          '${item.quantity} ${item.unit} · ${item.market}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                        ),
                      ],
                    ),
                  ),
                  Text(_fmt(item.total),
                      style: const TextStyle(color: Color(0xFFC0392B), fontWeight: FontWeight.w800)),
                  IconButton(
                    onPressed: () => _removeItem(item.id),
                    icon: const Icon(Icons.close, color: Color(0xFFCCCCCC)),
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 8),
        _showAddForm ? _addForm() : _addFormToggle(),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('CHI THEO NHÓM (Danh sách hiện tại)', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              ..._categories.map((String c) {
                final double catTotal = _currentItems
                    .where((ShoppingItem i) => i.category == c)
                    .fold(0, (double s, ShoppingItem i) => s + i.total);
                if (catTotal == 0) return const SizedBox.shrink();
                final double pct = (catTotal / (_totalEstimated == 0 ? 1 : _totalEstimated)).clamp(0, 1);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(c, style: const TextStyle(fontSize: 12)),
                          Text(_fmt(catTotal), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: pct,
                        minHeight: 4,
                        backgroundColor: const Color(0xFFF0F0F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC0392B)),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _addFormToggle() {
    return OutlinedButton(
      onPressed: () => setState(() => _showAddForm = true),
      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
      child: const Text('+ THÊM MÓN VÀO DANH SÁCH'),
    );
  }

  Widget _addForm() {
    final _SmartSuggestion? hint = _smartSuggestion;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFBE8D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('➕ THÊM MÓN MỚI',
              style: TextStyle(color: Color(0xFFC0392B), fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          TextField(
            controller: _nameCtrl,
            onChanged: (_) => setState(() => _isTypingName = true),
            onTap: () => setState(() => _isTypingName = true),
            decoration: _inputStyle('Gõ tên món'),
          ),
          if (_isTypingName && _nameSuggestions.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Column(
                children: _nameSuggestions.map((String s) {
                  return ListTile(
                    dense: true,
                    title: Text(s, style: const TextStyle(fontSize: 13)),
                    trailing: const Icon(Icons.chevron_right, size: 16),
                    onTap: () => _selectSuggestion(s),
                  );
                }).toList(),
              ),
            ),
          ],
          if (hint != null) ...<Widget>[
            const SizedBox(height: 8),
            InkWell(
              onTap: _applySmartDetails,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBCF0DA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('GỢI Ý TỪ LỊCH SỬ GIÁ',
                        style: TextStyle(fontSize: 11, color: Color(0xFF166534), fontWeight: FontWeight.w700)),
                    Text('Khoảng giá: ${_fmt(hint.min)} - ${_fmt(hint.max)}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF065F46))),
                    Text('Rẻ nhất tại: ${hint.cheapestMarket}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF059669))),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputStyle('SL'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _unitCtrl,
                  decoration: _inputStyle('Đơn vị (vd: kg, cái, hộp...)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            decoration: _inputStyle('Giá (đ)'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _marketForm,
            decoration: _inputStyle('Chợ'),
            items: _markets.map((String m) => DropdownMenuItem<String>(value: m, child: Text(m))).toList(),
            onChanged: (String? v) {
              if (v != null) setState(() => _marketForm = v);
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _categoryForm,
            decoration: _inputStyle('Danh mục'),
            items: _categories.map((String c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
            onChanged: (String? v) {
              if (v != null) setState(() => _categoryForm = v);
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton(
                  onPressed: _addItem,
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC0392B)),
                  child: const Text('XÁC NHẬN'),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => setState(() {
                  _showAddForm = false;
                  _selectedItemName = '';
                }),
                child: const Text('HỦY'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _compareTab() {
    final List<_MarketPriceRow> rows = _compareRows;
    final double maxPrice = rows.isEmpty ? 1 : rows.map(( _MarketPriceRow r) => r.price).reduce(max);
    return Column(
      children: <Widget>[
        if (!_showCompareInput)
          FilledButton.icon(
            onPressed: () => setState(() => _showCompareInput = true),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('NẠP DỮ LIỆU GIÁ MỚI'),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFBE8D0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const Expanded(
                      child: Text('📊 KHẢO SÁT GIÁ', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _showCompareInput = false),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                TextField(controller: _compareItemCtrl, decoration: _inputStyle('Tên món')),
                const SizedBox(height: 8),
                TextField(controller: _compareUnitCtrl, decoration: _inputStyle('Đơn vị (vd: kg, cái, hộp...)')),
                const SizedBox(height: 8),
                ..._compareDrafts.asMap().entries.map((MapEntry<int, CompareDraftV2> e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: e.value.market,
                            decoration: _inputStyle('Chợ'),
                            items: _markets
                                .map((String m) => DropdownMenuItem<String>(value: m, child: Text(m)))
                                .toList(),
                            onChanged: (String? v) {
                              if (v != null) setState(() => e.value.market = v);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 120,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            decoration: _inputStyle('Giá'),
                            onChanged: (String v) => e.value.price = v,
                          ),
                        ),
                        if (e.key > 0)
                          IconButton(
                            onPressed: () => setState(() => _compareDrafts.removeAt(e.key)),
                            icon: const Icon(Icons.close),
                          ),
                      ],
                    ),
                  );
                }),
                TextButton(
                  onPressed: () => setState(() => _compareDrafts.add(CompareDraftV2(market: _markets.first))),
                  child: const Text('+ Thêm nơi khảo giá'),
                ),
                if (_compareItemCtrl.text.trim().isNotEmpty && rows.isNotEmpty) ...<Widget>[
                  const Divider(),
                  Text(
                    'KẾT QUẢ: ${_compareItemCtrl.text.trim().toUpperCase()} (${_compareUnitCtrl.text.trim().isEmpty ? 'đơn vị' : _compareUnitCtrl.text.trim()})',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFC0392B))),
                  const SizedBox(height: 8),
                  ...rows.asMap().entries.map((MapEntry<int, _MarketPriceRow> entry) {
                    final bool cheapest = entry.key == 0;
                    final double ratio = entry.value.price / maxPrice;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Text(entry.value.market)),
                          SizedBox(
                            width: 90,
                            child: LinearProgressIndicator(
                              value: ratio.clamp(0, 1),
                              minHeight: 6,
                              backgroundColor: const Color(0xFFF0E0D0),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                cheapest ? const Color(0xFF27AE60) : const Color(0xFFE74C3C),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(_fmt(entry.value.price),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: cheapest ? const Color(0xFF27AE60) : const Color(0xFFE74C3C),
                              )),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: _saveOnlyToHistory,
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC0392B)),
                    child: const Text('LƯU VÀO LỊCH SỬ GIÁ'),
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 14),
        _historySection(),
      ],
    );
  }

  Widget _historySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text('DỮ LIỆU GIÁ (${_priceHistory.length})',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF333333))),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _historySearchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: _inputStyle('Tìm...'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._historyGroups.entries.map((MapEntry<String, List<PriceHistoryEntry>> group) {
            final String groupKey = group.key;
            final List<String> parts = groupKey.split('__');
            final String itemName = parts.first;
            final String itemUnit = parts.length > 1 ? parts[1] : 'đơn vị';
            final List<PriceHistoryEntry> entries = group.value;
            final bool expanded = _expandedHistoryNames.contains(groupKey);
            final List<double> prices = entries.map((PriceHistoryEntry e) => e.price).toList();
            final double minPrice = prices.reduce(min);
            final double maxPrice = prices.reduce(max);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF0F0F0)),
              ),
              child: Column(
                children: <Widget>[
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        if (expanded) {
                          _expandedHistoryNames.remove(groupKey);
                        } else {
                          _expandedHistoryNames.add(groupKey);
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(itemName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text(
                                  '${entries.length} nơi bán · $itemUnit · ${_fmt(minPrice)} - ${_fmt(maxPrice)}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: const Color(0xFF999999),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (expanded)
                    ...entries.map((PriceHistoryEntry h) {
                    final bool editing = _editingHistoryId == h.id;
                      if (editing) {
                        return Container(
                          margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFAF5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFF0D0B0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(h.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                initialValue: _editMarket,
                                decoration: _inputStyle('Chợ'),
                                items: _markets
                                    .map((String m) => DropdownMenuItem<String>(value: m, child: Text(m)))
                                    .toList(),
                                onChanged: (String? v) {
                                  if (v != null) setState(() => _editMarket = v);
                                },
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _editUnitCtrl,
                                decoration: _inputStyle('Đơn vị (vd: kg, cái, hộp...)'),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _editPriceCtrl,
                                keyboardType: TextInputType.number,
                                decoration: _inputStyle('Giá'),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: FilledButton(
                                      onPressed: () => _saveEditHistory(h.id),
                                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF27AE60)),
                                      child: const Text('Lưu'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => setState(() => _editingHistoryId = null),
                                      child: const Text('Hủy'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                      return Container(
                        margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCFCFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFF3F3F3)),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                '📍 ${h.market} · ${h.unit.trim().isEmpty ? 'đơn vị' : h.unit} · ${_fmt(h.price)}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _startEditHistory(h),
                              icon: const Icon(Icons.edit, color: Color(0xFF3498DB)),
                            ),
                            IconButton(
                              onPressed: () => _deleteHistoryItem(h.id),
                              icon: const Icon(Icons.delete, color: Color(0xFFE74C3C)),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _summaryTab() {
    final int doneCount = _allItems.where((ShoppingItem i) => i.isBought).length;
    final int progress = ((_allTotalDone / (_allTotalEstimated == 0 ? 1 : _allTotalEstimated)) * 100).round();
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: <Widget>[
              const Text('PHÂN TÍCH TỔNG HỢP', style: TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text('Tất cả danh sách', style: const TextStyle(color: Color(0xFF999999), fontSize: 12)),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(child: _summaryMetric('Tổng dự kiến', _fmt(_allTotalEstimated), const Color(0xFFC0392B))),
                  const SizedBox(width: 8),
                  Expanded(child: _summaryMetric('Đã mua', '$doneCount/${_allItems.length} món', const Color(0xFF27AE60))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('Tiến độ', style: TextStyle(fontWeight: FontWeight.w700)),
                  Text('$progress%', style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: (progress / 100).clamp(0, 1),
                minHeight: 6,
                backgroundColor: const Color(0xFFEEEEEE),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF27AE60)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('TỔNG THEO TỪNG DANH SÁCH', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              ..._shoppingLists.map((ShoppingCollection list) {
                final List<ShoppingItem> items = list.items;
                final double listTotal = items.fold(0, (double s, ShoppingItem i) => s + i.total);
                final double listDone =
                    items.where((ShoppingItem i) => i.isBought).fold(0, (double s, ShoppingItem i) => s + i.total);
                if (listTotal == 0 && items.isEmpty) return const SizedBox.shrink();
                final double pct = (listDone / (listTotal == 0 ? 1 : listTotal)).clamp(0, 1);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(list.name, style: const TextStyle(fontSize: 12)),
                          Text(_fmt(listTotal), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: pct,
                        minHeight: 4,
                        backgroundColor: const Color(0xFFF0F0F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF27AE60)),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryMetric(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _currentTab() {
    if (_activeTab == 'compare') return _compareTab();
    if (_activeTab == 'summary') return _summaryTab();
    return _listTab();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _header(),
            _statusBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: _currentTab(),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
              child: Text(
                'TET SMART SHOPPING 2026',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0x55333333),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmartSuggestion {
  _SmartSuggestion({
    required this.min,
    required this.max,
    required this.cheapestMarket,
  });

  final double min;
  final double max;
  final String cheapestMarket;
}

class _MarketPriceRow {
  _MarketPriceRow({required this.market, required this.price});

  final String market;
  final double price;
}
