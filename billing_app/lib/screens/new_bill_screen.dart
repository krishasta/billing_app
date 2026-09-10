import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bill.dart';
import '../models/bill_item.dart';
import '../models/product.dart';
import '../models/shop_profile.dart';
import '../services/default_data.dart';
import '../services/storage_service.dart';
import 'bill_preview_screen.dart';

class NewBillScreen extends StatefulWidget {
  const NewBillScreen({super.key});

  @override
  State<NewBillScreen> createState() => _NewBillScreenState();
}

class _NewBillScreenState extends State<NewBillScreen> {
  final _customerNameCtrl = TextEditingController();
  final _customerPhoneCtrl = TextEditingController();
  final _customerAddressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _advancePaidCtrl = TextEditingController(text: '0');

  List<Product> _allProducts = [];
  final Map<String, int> _cartQuantities = {}; // product.id -> quantity
  final Map<String, double> _customUnitPrices = {}; // product.id -> custom rate if modified

  String _selectedCategory = 'All';
  String _searchQuery = '';
  double _discountPercent = 81.0;
  bool _isLoading = true;
  bool _showCustomerDetails = true;
  late ShopProfile _shopProfile;

  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  final shortCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prods = await StorageService.getProducts();
    final profile = await StorageService.getShopProfile();
    setState(() {
      _allProducts = prods;
      _shopProfile = profile;
      _discountPercent = profile.defaultDiscountPercent;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _customerPhoneCtrl.dispose();
    _customerAddressCtrl.dispose();
    _notesCtrl.dispose();
    _advancePaidCtrl.dispose();
    super.dispose();
  }

  void _updateQuantity(Product product, int delta) {
    setState(() {
      final current = _cartQuantities[product.id] ?? 0;
      final next = current + delta;
      if (next <= 0) {
        _cartQuantities.remove(product.id);
      } else {
        _cartQuantities[product.id] = next;
      }
    });
  }

  void _setDirectQuantity(Product product, int qty) {
    setState(() {
      if (qty <= 0) {
        _cartQuantities.remove(product.id);
      } else {
        _cartQuantities[product.id] = qty;
      }
    });
  }

  List<BillItem> get _selectedBillItems {
    final list = <BillItem>[];
    for (final entry in _cartQuantities.entries) {
      if (entry.value > 0) {
        final product = _allProducts.firstWhere(
          (p) => p.id == entry.key,
          orElse: () => Product(id: entry.key, name: 'Item', category: 'General', price: 0),
        );
        final rate = _customUnitPrices[product.id] ?? product.price;
        list.add(BillItem(product: product, quantity: entry.value, unitPrice: rate));
      }
    }
    return list;
  }

  double get _cartSubtotal {
    double sum = 0;
    for (final item in _selectedBillItems) {
      sum += item.totalPrice;
    }
    return sum;
  }

  double get _cartDiscountAmount => _cartSubtotal * (_discountPercent / 100);

  double get _cartGrandTotal => (_cartSubtotal - _cartDiscountAmount).clamp(0.0, double.infinity);

  int get _totalPieces => _selectedBillItems.fold(0, (sum, i) => sum + i.quantity);

  List<Product> get _filteredProducts {
    return _allProducts.where((p) {
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.subtitle != null && p.subtitle!.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesSearch;
    }).toList();
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'All':
        return '✨';
      case 'One Sound Crackers':
        return '🔥';
      case 'Wala':
        return '🧨';
      case 'Bijili Crackers':
        return '💥';
      case 'Bomb':
        return '💣';
      case 'Naattu Vedi':
        return '💥';
      case 'Ground Chakkar':
        return '🌀';
      case 'Flower Pots':
        return '🪔';
      case 'Sky Shot Repeating':
        return '🎆';
      case 'Sky Shot Pack':
        return '🚀';
      case 'Sparklers':
        return '✨';
      case 'Twinkling Stars':
        return '⭐';
      case 'Match Box':
        return '📦';
      case 'Gift Box':
      case 'Family Pack':
        return '🎁';
      case '2026 Series New Arrival':
        return '🌟';
      default:
        return '🎆';
    }
  }

  void _showCustomPriceDialog(Product product) {
    final currentRate = _customUnitPrices[product.id] ?? product.price;
    final ctrl = TextEditingController(text: currentRate.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Rate for ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Original MRP: ₹${product.price.toStringAsFixed(2)} / ${product.unit}'),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Unit MRP Rate (₹)',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _customUnitPrices.remove(product.id);
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Reset to Default'),
          ),
          ElevatedButton(
            onPressed: () {
              final newRate = double.tryParse(ctrl.text.trim());
              if (newRate != null && newRate > 0) {
                setState(() {
                  _customUnitPrices[product.id] = newRate;
                });
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save Rate'),
          ),
        ],
      ),
    );
  }

  void _showCartReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final items = _selectedBillItems;
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Sheet Handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Cart Summary',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${items.length} items',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Items List
                Expanded(
                  child: items.isEmpty
                      ? const Center(child: Text('No items in cart'))
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (ctx, idx) {
                            final item = items[idx];
                            final netItemRate = item.unitPrice * (1 - _discountPercent / 100);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'MRP: ₹${item.unitPrice.toStringAsFixed(2)} · Net: ₹${netItemRate.toStringAsFixed(2)} / ${item.product.unit}',
                                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF6E5E52)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Stepper in sheet
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3ECE0),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove, size: 16),
                                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            _updateQuantity(item.product, -1);
                                            setSheetState(() {});
                                          },
                                        ),
                                        Text(
                                          '${item.quantity}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add, size: 16),
                                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            _updateQuantity(item.product, 1);
                                            setSheetState(() {});
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    shortCurrency.format(netItemRate * item.quantity),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF8B1E0F),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF8F2),
                    border: Border(top: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Catalogue MRP Total:'),
                          Text(currencyFormat.format(_cartSubtotal)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Festival Discount ($_discountPercent%):',
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          Text('- ${currencyFormat.format(_cartDiscountAmount)}',
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Net Payable Amount:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(currencyFormat.format(_cartGrandTotal),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF8B1E0F))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            _generateAndPreviewBill();
                          },
                          child: const Text('PROCEED TO INVOICE ➔'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _generateAndPreviewBill() async {
    if (_selectedBillItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one cracker item to generate bill!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final billId = await StorageService.generateNextBillId();
    final customerName = _customerNameCtrl.text.trim().isEmpty ? 'Valued Customer' : _customerNameCtrl.text.trim();
    final customerPhone = _customerPhoneCtrl.text.trim();
    final customerAddress = _customerAddressCtrl.text.trim();
    final notes = _notesCtrl.text.trim();
    final advancePaid = double.tryParse(_advancePaidCtrl.text.trim()) ?? 0.0;

    final bill = Bill(
      id: billId,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      date: DateTime.now(),
      items: _selectedBillItems,
      discountPercent: _discountPercent,
      advancePaid: advancePaid,
      notes: notes,
    );

    // Save bill to local storage
    await StorageService.saveBill(bill);

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BillPreviewScreen(bill: bill, shop: _shopProfile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF8B1E0F))),
      );
    }

    final categories = DefaultData.crackerCategories;
    final filtered = _filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Bill'),
        actions: [
          // Quick Cart count badge
          if (_selectedBillItems.isNotEmpty)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  onPressed: _showCartReviewSheet,
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${_selectedBillItems.length}',
                      style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      bottomNavigationBar: _selectedBillItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _showCartReviewSheet,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${_selectedBillItems.length} items ($_totalPieces pcs)',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.keyboard_arrow_up, size: 16, color: Color(0xFF8B1E0F)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  shortCurrency.format(_cartGrandTotal),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF8B1E0F),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Save ${shortCurrency.format(_cartDiscountAmount)}',
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _generateAndPreviewBill,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B1E0F),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Row(
                        children: [
                          Text('INVOICE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: Column(
        children: [
          // 1. Collapsible Customer & Discount Info Card
          Container(
            margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEAD8C3)),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () => setState(() => _showCustomerDetails = !_showCustomerDetails),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_pin_rounded, color: Color(0xFF8B1E0F), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _customerNameCtrl.text.isEmpty
                                  ? 'Customer Details & Discount ($_discountPercent%)'
                                  : '${_customerNameCtrl.text} (${_customerPhoneCtrl.text.isEmpty ? "No Phone" : _customerPhoneCtrl.text}) · $_discountPercent% Off',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        Icon(
                          _showCustomerDetails ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: const Color(0xFF786A5E),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showCustomerDetails) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _customerNameCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Customer Name',
                                  prefixIcon: Icon(Icons.person_outline, size: 18),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _customerPhoneCtrl,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Mobile No.',
                                  prefixIcon: Icon(Icons.phone_android, size: 18),
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _customerAddressCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'City / Delivery Location',
                                  prefixIcon: Icon(Icons.location_on_outlined, size: 18),
                                  isDense: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _advancePaidCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Advance Paid (₹)',
                                  prefixIcon: Icon(Icons.payments_outlined, size: 18),
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Quick Discount Selector Pills
                        Row(
                          children: [
                            const Text('Discount:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [70.0, 75.0, 80.0, 81.0, 85.0].map((d) {
                                    final isSelected = _discountPercent == d;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: ChoiceChip(
                                        label: Text('${d.toStringAsFixed(0)}%'),
                                        selected: isSelected,
                                        onSelected: (sel) {
                                          if (sel) setState(() => _discountPercent = d);
                                        },
                                        selectedColor: const Color(0xFF8B1E0F),
                                        labelStyle: TextStyle(
                                          color: isSelected ? Colors.white : const Color(0xFF1E130D),
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 2. Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search sparklers, rockets, pots, bombs...',
                hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9E8E81)),
                prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF8B1E0F)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),

          // 3. Category Horizontal Pills
          SizedBox(
            height: 46,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              itemCount: categories.length,
              itemBuilder: (ctx, idx) {
                final cat = categories[idx];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: FilterChip(
                    avatar: Text(_getCategoryEmoji(cat), style: const TextStyle(fontSize: 13)),
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (sel) => setState(() => _selectedCategory = cat),
                    selectedColor: const Color(0xFF8B1E0F),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF281810),
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF8B1E0F) : const Color(0xFFEAD8C3),
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 4),

          // 4. Products List
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No matching cracker items found.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, idx) {
                      final p = filtered[idx];
                      final unitPrice = _customUnitPrices[p.id] ?? p.price;
                      final netPrice = unitPrice * (1 - _discountPercent / 100);
                      final qty = _cartQuantities[p.id] ?? 0;
                      final isCustomRate = _customUnitPrices.containsKey(p.id);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Left info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF3ECE0),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            p.category,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF786A5E),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8F5E9),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'Eco Safe',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2E7D32),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      p.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.5,
                                        color: Color(0xFF1E130D),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '₹${netPrice.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF8B1E0F),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '₹${unitPrice.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            decoration: TextDecoration.lineThrough,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '/ ${p.unit}',
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF786A5E)),
                                        ),
                                        if (isCustomRate) ...[
                                          const SizedBox(width: 6),
                                          const Text(
                                            '(Custom)',
                                            style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 14, color: Colors.grey),
                                          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                          padding: EdgeInsets.zero,
                                          tooltip: 'Edit unit rate',
                                          onPressed: () => _showCustomPriceDialog(p),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Right Stepper Button
                              if (qty == 0)
                                ElevatedButton.icon(
                                  onPressed: () => _updateQuantity(p, 1),
                                  icon: const Icon(Icons.add, size: 15),
                                  label: const Text('ADD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8B1E0F),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                )
                              else
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B1E0F),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 16, color: Colors.white),
                                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                        padding: EdgeInsets.zero,
                                        onPressed: () => _updateQuantity(p, -1),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          // Prompt quick number edit
                                          final qtyCtrl = TextEditingController(text: '$qty');
                                          showDialog(
                                            context: context,
                                            builder: (dialogCtx) => AlertDialog(
                                              title: Text('Quantity for ${p.name}'),
                                              content: TextField(
                                                controller: qtyCtrl,
                                                keyboardType: TextInputType.number,
                                                autofocus: true,
                                                decoration: InputDecoration(
                                                  labelText: 'Quantity (${p.unit})',
                                                  border: const OutlineInputBorder(),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(dialogCtx).pop(),
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    final val = int.tryParse(qtyCtrl.text.trim()) ?? 0;
                                                    _setDirectQuantity(p, val);
                                                    Navigator.of(dialogCtx).pop();
                                                  },
                                                  child: const Text('Set'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Text(
                                            '$qty',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 16, color: Colors.white),
                                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                        padding: EdgeInsets.zero,
                                        onPressed: () => _updateQuantity(p, 1),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
