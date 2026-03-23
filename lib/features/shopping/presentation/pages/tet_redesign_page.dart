import 'package:flutter/material.dart';
import 'package:tet_shop/features/shopping/models/compare_draft_v2.dart';
import 'package:tet_shop/features/shopping/models/price_entry.dart';
import 'package:tet_shop/features/shopping/models/shopping_collection.dart';
import 'package:tet_shop/features/shopping/models/shopping_item.dart';

class TetRedesignPage extends StatefulWidget {
  const TetRedesignPage({super.key});

  @override
  State<TetRedesignPage> createState() => _TetRedesignPageState();
}

class _TetRedesignPageState extends State<TetRedesignPage> {
  final List<String> _markets = <String>[
    'Chợ Đồng Xuân',
    'Chợ Hôm',
    'Vinmart',
    'Siêu thị Big C',
    'Chợ gần nhà',
  ];
  final List<String> _categories = <String>[
    'Thực phẩm',
    'Bánh kẹo',
    'Hoa quả',
    'Trang trí',
    'Quần áo',
    'Khác',
  ];

  final List<ShoppingCollection> _shoppingLists = <ShoppingCollection>[
    ShoppingCollection(
      id: 'tet-2026',
      name: 'Tết 2026',
      items: <ShoppingItem>[
        ShoppingItem(
          id: '1',
          name: 'Bánh chưng',
          quantity: 4,
          unit: 'cái',
          estimatedPrice: 80000,
          market: 'Chợ Đồng Xuân',
          category: 'Thực phẩm',
          isBought: false,
        ),
        ShoppingItem(
          id: '2',
          name: 'Mứt tết',
          quantity: 2,
          unit: 'hộp',
          estimatedPrice: 120000,
          market: 'Vinmart',
          category: 'Bánh kẹo',
          isBought: false,
        ),
        ShoppingItem(
          id: '3',
          name: 'Hoa đào',
          quantity: 1,
          unit: 'cành',
          estimatedPrice: 350000,
          market: 'Chợ Hôm',
          category: 'Trang trí',
          isBought: true,
        ),
        ShoppingItem(
          id: '4',
          name: 'Bưởi',
          quantity: 3,
          unit: 'quả',
          estimatedPrice: 45000,
          market: 'Chợ gần nhà',
          category: 'Hoa quả',
          isBought: false,
        ),
      ],
    ),
  ];
  String _activeListId = 'tet-2026';

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _qtyCtrl = TextEditingController(text: '1');
  final TextEditingController _unitCtrl = TextEditingController(text: 'cái');
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _compareItemCtrl = TextEditingController();
  final TextEditingController _newListNameCtrl = TextEditingController();

  final List<CompareDraftV2> _compareDrafts = <CompareDraftV2>[CompareDraftV2(market: 'Chợ Đồng Xuân')];

  String _activeTab = 'list';
  String _filter = 'Tất cả';
  bool _showForm = false;
  bool _isCreatingList = false;
  String _marketForm = 'Chợ Đồng Xuân';
  String _categoryForm = 'Thực phẩm';

  ShoppingCollection get _activeCollection {
    return _shoppingLists.firstWhere((ShoppingCollection e) => e.id == _activeListId);
  }

  List<ShoppingItem> get _items => _activeCollection.items;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _unitCtrl.dispose();
    _priceCtrl.dispose();
    _compareItemCtrl.dispose();
    _newListNameCtrl.dispose();
    super.dispose();
  }

  List<ShoppingItem> get _filtered =>
      _items.where((ShoppingItem i) => _filter == 'Tất cả' || i.market == _filter).toList();

  double get _totalEst => _items.fold(0, (double s, ShoppingItem i) => s + i.total);
  double get _totalDone =>
      _items.where((ShoppingItem i) => i.isBought).fold(0, (double s, ShoppingItem i) => s + i.total);
  double get _totalPending => _totalEst - _totalDone;
  double get _progress => _totalEst == 0 ? 0 : (_totalDone / _totalEst).clamp(0, 1);

  String _fmt(double n) {
    final String digits = n.round().toString();
    final RegExp regExp = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return '${digits.replaceAllMapped(regExp, (Match m) => '.')}đ';
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFFFFAF5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFF0D0B0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFC0392B)),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFF0D0B0)),
      ),
    );
  }

  void _toggle(String id) {
    setState(() {
      final int idx = _items.indexWhere((ShoppingItem i) => i.id == id);
      if (idx != -1) _items[idx].isBought = !_items[idx].isBought;
    });
  }

  void _remove(String id) {
    setState(() => _items.removeWhere((ShoppingItem i) => i.id == id));
  }

  void _addItem() {
    final String name = _nameCtrl.text.trim();
    final double qty = double.tryParse(_qtyCtrl.text.trim()) ?? 0;
    final double price = double.tryParse(_priceCtrl.text.trim()) ?? 0;
    final String unit = _unitCtrl.text.trim().isEmpty ? 'cái' : _unitCtrl.text.trim();
    if (name.isEmpty || qty <= 0 || price <= 0) return;

    setState(() {
      _items.add(
        ShoppingItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: name,
          quantity: qty,
          unit: unit,
          estimatedPrice: price,
          market: _marketForm,
          category: _categoryForm,
        ),
      );
      _nameCtrl.clear();
      _qtyCtrl.text = '1';
      _unitCtrl.text = 'cái';
      _priceCtrl.clear();
      _showForm = false;
    });
  }

  void _startCreateList() {
    setState(() {
      _isCreatingList = true;
      _newListNameCtrl.clear();
    });
  }

  void _cancelCreateList() {
    setState(() {
      _isCreatingList = false;
      _newListNameCtrl.clear();
    });
  }

  void _confirmCreateList() {
    final String name = _newListNameCtrl.text.trim();
    if (name.isEmpty) return;
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _shoppingLists.add(
        ShoppingCollection(id: id, name: name, items: <ShoppingItem>[]),
      );
      _activeListId = id;
      _filter = 'Tất cả';
      _showForm = false;
      _isCreatingList = false;
      _newListNameCtrl.clear();
    });
  }

  List<PriceEntry> get _compareResult {
    final List<PriceEntry> entries = _compareDrafts
        .map((CompareDraftV2 d) => PriceEntry(
              market: d.market,
              price: double.tryParse(d.price.trim()) ?? 0,
            ))
        .where((PriceEntry e) => e.price > 0)
        .toList();
    entries.sort((PriceEntry a, PriceEntry b) => a.price.compareTo(b.price));
    return entries;
  }

  void _assignCheapest() {
    final String compareItem = _compareItemCtrl.text.trim().toLowerCase();
    if (compareItem.isEmpty || _compareResult.isEmpty) return;
    final PriceEntry cheapest = _compareResult.first;
    setState(() {
      for (int i = 0; i < _items.length; i++) {
        if (_items[i].name.toLowerCase() == compareItem) {
          _items[i] = ShoppingItem(
            id: _items[i].id,
            name: _items[i].name,
            quantity: _items[i].quantity,
            unit: _items[i].unit,
            estimatedPrice: cheapest.price,
            market: cheapest.market,
            category: _items[i].category,
            isBought: _items[i].isBought,
          );
        }
      }
    });
  }

  Widget _topHeader() {
    final List<(String, String)> tabs = <(String, String)>[
      ('list', '🧾 Danh sách'),
      ('compare', '📊 So sánh giá'),
      ('summary', '💰 Tổng kết'),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 14),
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
          const Text(
            '🧧 Chợ Tết Thông Minh',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 34),
          ),
          const SizedBox(height: 4),
          const Text(
            'Quản lý mua sắm tết - không bỏ sót, không overspend',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white38),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _activeListId,
                      isExpanded: true,
                      dropdownColor: const Color(0xFFE74C3C),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      iconEnabledColor: Colors.white,
                      items: _shoppingLists
                          .map(
                            (ShoppingCollection e) => DropdownMenuItem<String>(
                              value: e.id,
                              child: Text(e.name),
                            ),
                          )
                          .toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            _activeListId = value;
                            _filter = 'Tất cả';
                            _showForm = false;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (!_isCreatingList)
                OutlinedButton(
                  onPressed: _startCreateList,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white70),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('+ Danh sách'),
                ),
            ],
          ),
          if (_isCreatingList) ...<Widget>[
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _newListNameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Tên danh sách (vd: Trung thu 2026)',
                      hintStyle: const TextStyle(color: Colors.white70),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      filled: true,
                      fillColor: Colors.white24,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white38),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _confirmCreateList,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFC0392B),
                  ),
                  child: const Text('Tạo'),
                ),
                const SizedBox(width: 6),
                TextButton(
                  onPressed: _cancelCreateList,
                  child: const Text(
                    'Hủy',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: tabs.map(((String, String) tab) {
              final bool active = _activeTab == tab.$1;
              return OutlinedButton(
                onPressed: () => setState(() => _activeTab = tab.$1),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: active ? Colors.white24 : Colors.white10,
                  side: BorderSide(color: active ? Colors.white : Colors.white38, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                child: Text(
                  tab.$2,
                  style: TextStyle(fontWeight: active ? FontWeight.w700 : FontWeight.w500),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _budgetRow() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: <Widget>[
          _budgetMetric('Tổng dự kiến', _fmt(_totalEst), const Color(0xFFC0392B)),
          const SizedBox(width: 20),
          _budgetMetric('Đã mua', _fmt(_totalDone), const Color(0xFF27AE60)),
          const SizedBox(width: 20),
          _budgetMetric('Còn lại', _fmt(_totalPending), const Color(0xFFE67E22)),
          const Spacer(),
          SizedBox(
            width: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: const Color(0xFFF0E0D0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF27AE60)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('${(_progress * 100).round()}%', style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
        ],
      ),
    );
  }

  Widget _budgetMetric(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
        Text(value, style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _listTab() {
    return Column(
      children: <Widget>[
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: <String>['Tất cả', ..._markets].map((String m) {
              final bool active = _filter == m;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _filter = m),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFFC0392B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 1)),
                      ],
                    ),
                    child: Text(
                      m,
                      style: TextStyle(
                        fontSize: 12,
                        color: active ? Colors.white : const Color(0xFF555555),
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        ..._filtered.map((ShoppingItem item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: item.isBought ? const Color(0xFFF9F9F9) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: item.isBought ? const Color(0xFFEEEEEE) : const Color(0xFFFDE8D0)),
              boxShadow: const <BoxShadow>[
                BoxShadow(color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              children: <Widget>[
                Checkbox(
                  value: item.isBought,
                  onChanged: (_) => _toggle(item.id),
                  activeColor: const Color(0xFFC0392B),
                  side: const BorderSide(color: Color(0xFFC0392B)),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: item.isBought ? const Color(0xFFAAAAAA) : const Color(0xFF333333),
                          decoration: item.isBought ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      Text(
                        '${item.quantity.toStringAsFixed(item.quantity % 1 == 0 ? 0 : 1)} ${item.unit} · ${item.category} · 📍${item.market}',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(_fmt(item.estimatedPrice),
                        style: const TextStyle(fontSize: 14, color: Color(0xFFC0392B), fontWeight: FontWeight.w700)),
                    Text('= ${_fmt(item.total)}', style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA))),
                  ],
                ),
                IconButton(
                  onPressed: () => _remove(item.id),
                  icon: const Icon(Icons.close, color: Color(0xFFDDDDDD)),
                ),
              ],
            ),
          );
        }),
        if (_showForm)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFDE8D0)),
              boxShadow: const <BoxShadow>[
                BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  '➕ Thêm món mới',
                  style: TextStyle(color: Color(0xFFC0392B), fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 10),
                TextField(controller: _nameCtrl, decoration: _inputStyle('Tên món *')),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _qtyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: _inputStyle('SL'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: _unitCtrl, decoration: _inputStyle('ĐV'))),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: _inputStyle('Giá (đ) *'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _marketForm,
                  decoration: _inputStyle('Nơi mua'),
                  items: _markets.map((String m) => DropdownMenuItem<String>(value: m, child: Text(m))).toList(),
                  onChanged: (String? v) {
                    if (v != null) setState(() => _marketForm = v);
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _categoryForm,
                  decoration: _inputStyle('Danh mục'),
                  items: _categories.map((String c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
                  onChanged: (String? v) {
                    if (v != null) setState(() => _categoryForm = v);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    FilledButton(
                      onPressed: _addItem,
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC0392B)),
                      child: const Text('Thêm'),
                    ),
                    const SizedBox(width: 10),
                    TextButton(onPressed: () => setState(() => _showForm = false), child: const Text('Hủy')),
                  ],
                ),
              ],
            ),
          )
        else
          OutlinedButton(
            onPressed: () => setState(() => _showForm = true),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              side: const BorderSide(color: Color(0xFFF0B080), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              foregroundColor: const Color(0xFFE67E22),
            ),
            child: const Text('+ Thêm đồ cần mua', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ),
      ],
    );
  }

  Widget _compareTab() {
    final List<PriceEntry> ranked = _compareResult;
    final String compareItem = _compareItemCtrl.text.trim();
    final double maxPrice = ranked.isEmpty
        ? 0
        : ranked.map((PriceEntry p) => p.price).reduce((double a, double b) => a > b ? a : b);

    final Map<String, List<ShoppingItem>> byMarket = <String, List<ShoppingItem>>{};
    for (final ShoppingItem i in _items) {
      byMarket.putIfAbsent(i.market, () => <ShoppingItem>[]);
      byMarket[i.market]!.add(i);
    }

    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('📊 So sánh giá theo nơi mua', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: _compareItemCtrl,
                onChanged: (_) => setState(() {}),
                decoration: _inputStyle('Tên mặt hàng cần so sánh...'),
              ),
              const SizedBox(height: 12),
              ..._compareDrafts.asMap().entries.map((MapEntry<int, CompareDraftV2> row) {
                final int idx = row.key;
                final CompareDraftV2 draft = row.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: draft.market,
                          decoration: _inputStyle('Nơi bán'),
                          items: _markets
                              .map((String m) => DropdownMenuItem<String>(value: m, child: Text(m)))
                              .toList(),
                          onChanged: (String? v) {
                            if (v != null) setState(() => draft.market = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 130,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: _inputStyle('Giá (đ)'),
                          onChanged: (String v) => draft.price = v,
                        ),
                      ),
                      if (idx > 0)
                        IconButton(
                          onPressed: () => setState(() => _compareDrafts.removeAt(idx)),
                          style: IconButton.styleFrom(backgroundColor: const Color(0xFFFFEEEE)),
                          icon: const Icon(Icons.close, color: Color(0xFFC0392B)),
                        ),
                    ],
                  ),
                );
              }),
              TextButton(
                onPressed: () => setState(() => _compareDrafts.add(CompareDraftV2(market: _markets.first))),
                child: const Text('+ Thêm nơi so sánh'),
              ),
              if (compareItem.isNotEmpty && ranked.isNotEmpty) ...<Widget>[
                const Divider(color: Color(0xFFF0E0D0)),
                Text('Kết quả: $compareItem',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFC0392B))),
                const SizedBox(height: 10),
                ...ranked.asMap().entries.map((MapEntry<int, PriceEntry> row) {
                  final bool isCheapest = row.key == 0;
                  final double ratio = maxPrice == 0 ? 0 : row.value.price / maxPrice;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text(row.value.market)),
                        Container(
                          width: 120,
                          height: 8,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0E0D0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 120 * ratio,
                              color: isCheapest ? const Color(0xFF27AE60) : const Color(0xFFE74C3C),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 82,
                          child: Text(
                            _fmt(row.value.price),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isCheapest ? const Color(0xFF27AE60) : const Color(0xFFE74C3C),
                            ),
                          ),
                        ),
                        if (isCheapest)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD5F5E3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Rẻ nhất', style: TextStyle(fontSize: 11, color: Color(0xFF27AE60))),
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _assignCheapest,
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFC0392B)),
                  child: const Text('Gán [chợ] cho món này'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('🏪 Đồ nhóm theo chợ', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 10),
              ...byMarket.entries.map((MapEntry<String, List<ShoppingItem>> group) {
                final double total = group.value.fold(0, (double s, ShoppingItem i) => s + i.total);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '📍 ${group.key} (${group.value.length} món)',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFE67E22), fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      ...group.value.map((ShoppingItem i) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                '${i.name} × ${i.quantity.toStringAsFixed(i.quantity % 1 == 0 ? 0 : 1)}',
                                style: TextStyle(
                                  color: i.isBought ? const Color(0xFFBBBBBB) : const Color(0xFF333333),
                                  decoration: i.isBought ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              Text(_fmt(i.total), style: const TextStyle(color: Color(0xFFC0392B))),
                            ],
                          ),
                        );
                      }),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Tổng: ${_fmt(total)}',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFE67E22), fontSize: 12),
                        ),
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

  Widget _summaryCard({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(icon, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }

  Widget _summaryTab() {
    final List<ShoppingItem> pending = _items.where((ShoppingItem i) => !i.isBought).toList();
    final Map<String, List<ShoppingItem>> byCategory = <String, List<ShoppingItem>>{};
    for (final ShoppingItem i in _items) {
      byCategory.putIfAbsent(i.category, () => <ShoppingItem>[]);
      byCategory[i.category]!.add(i);
    }

    return Column(
      children: <Widget>[
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: <Widget>[
            _summaryCard(icon: '🧾', label: 'Tổng dự kiến', value: _fmt(_totalEst), color: const Color(0xFFC0392B)),
            _summaryCard(icon: '✅', label: 'Đã chi', value: _fmt(_totalDone), color: const Color(0xFF27AE60)),
            _summaryCard(
              icon: '🛒',
              label: 'Còn phải mua',
              value: _fmt(_totalPending),
              color: const Color(0xFFE67E22),
            ),
            _summaryCard(
              icon: '📦',
              label: 'Số món',
              value: '${_items.where((ShoppingItem i) => i.isBought).length}/${_items.length}',
              color: const Color(0xFF8E44AD),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Chi theo danh mục', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ..._categories.map((String c) {
                final List<ShoppingItem> cItems = byCategory[c] ?? <ShoppingItem>[];
                if (cItems.isEmpty) return const SizedBox.shrink();
                final double total = cItems.fold(0, (double s, ShoppingItem i) => s + i.total);
                final double pct = _totalEst == 0 ? 0 : (total / _totalEst).clamp(0, 1);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('$c (${cItems.length} món)'),
                          Text(_fmt(total), style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFF0E0D0),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC0392B)),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '🛒 Chưa mua (${pending.length} món)',
                style: const TextStyle(color: Color(0xFFE67E22), fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (pending.isEmpty)
                const Center(
                  child: Text(
                    '🎉 Mua xong hết rồi!',
                    style: TextStyle(color: Color(0xFF27AE60), fontWeight: FontWeight.w700),
                  ),
                )
              else
                ...pending.map((ShoppingItem i) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('${i.name} → ${i.market}'),
                        Text(
                          _fmt(i.total),
                          style: const TextStyle(color: Color(0xFFC0392B), fontWeight: FontWeight.w700),
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
            _topHeader(),
            _budgetRow(),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: 700,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                    child: _currentTab(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
