import 'package:flutter/material.dart';
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
  double _discountPercent = 70.0;
  bool _isLoading = true;
  late ShopProfile _shopProfile;

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
          p.category.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _showCartReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final items = _selectedBillItems;
          return DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, scrollController) => Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cart Items (${items.length})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.delete_sweep, color: Colors.red),
                        label: const Text('Clear All', style: TextStyle(color: Colors.red)),
                        onPressed: () {
                          setState(() => _cartQuantities.clear());
                          setSheetState(() {});
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: items.isEmpty
                      ? const Center(child: Text('No items in cart yet'))
                      : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: items.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (ctx, i) {
                            final item = items[i];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item.product.name,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(
                                '₹${item.unitPrice.toStringAsFixed(0)} / ${item.product.unit}  •  Total: ₹${item.totalPrice.toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.black54),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                    onPressed: () {
                                      _updateQuantity(item.product, -1);
                                      setSheetState(() {});
                                    },
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                    onPressed: () {
                                      _updateQuantity(item.product, 1);
                                      setSheetState(() {});
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                // Footer calculations
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(top: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal (Gross MRP):', style: TextStyle(color: Colors.black87)),
                          Text('₹${_cartSubtotal.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Festival Discount ($_discountPercent%):',
                              style: const TextStyle(color: Colors.green)),
                          Text('- ₹${_cartDiscountAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Net Payable:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('₹${_cartGrandTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8B0000))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            _generateBill();
                          },
                          icon: const Icon(Icons.receipt_long),
                          label: const Text('GENERATE & SHARE BILL',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B0000),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
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

  Future<void> _generateBill() async {
    final items = _selectedBillItems;
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one cracker item to the bill'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final billId = await StorageService.generateNextBillId();
    final advance = double.tryParse(_advancePaidCtrl.text.trim()) ?? 0.0;

    final bill = Bill(
      id: billId,
      customerName: _customerNameCtrl.text.trim().isEmpty ? 'Valued Customer' : _customerNameCtrl.text.trim(),
      customerPhone: _customerPhoneCtrl.text.trim(),
      customerAddress: _customerAddressCtrl.text.trim(),
      date: DateTime.now(),
      items: items,
      discountPercent: _discountPercent,
      advancePaid: advance,
      notes: _notesCtrl.text.trim(),
    );

    // Save offline
    await StorageService.saveBill(bill);

    if (!mounted) return;

    // Navigate to preview and share screen
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Crackers Bill'),
        actions: [
          if (_selectedBillItems.isNotEmpty)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  tooltip: 'View Cart',
                  onPressed: _showCartReviewSheet,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_selectedBillItems.length}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedBillItems.length} items ($_totalPieces pcs)',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          Row(
                            children: [
                              Text(
                                '₹${_cartGrandTotal.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8B0000),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'MRP ₹${_cartSubtotal.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _generateBill,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('CREATE BILL', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B0000),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: Column(
        children: [
          // Customer & Discount Info Accordion
          Card(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            elevation: 1.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ExpansionTile(
              initiallyExpanded: false,
              leading: const Icon(Icons.person, color: Color(0xFF8B0000)),
              title: Text(
                _customerNameCtrl.text.isNotEmpty
                    ? '${_customerNameCtrl.text} (${_customerPhoneCtrl.text.isEmpty ? "No Phone" : _customerPhoneCtrl.text})'
                    : 'Customer Details & Discount (${_discountPercent.toStringAsFixed(0)}% Off)',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Discount: ${_discountPercent.toStringAsFixed(0)}%  •  Advance: ₹${_advancePaidCtrl.text}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customerNameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Customer Name',
                                prefixIcon: Icon(Icons.person_outline),
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _customerPhoneCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Mobile / WhatsApp',
                                prefixIcon: Icon(Icons.phone_android),
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customerAddressCtrl,
                              decoration: const InputDecoration(
                                labelText: 'City / Place',
                                prefixIcon: Icon(Icons.location_city),
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _advancePaidCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: 'Advance Paid (₹)',
                                prefixIcon: Icon(Icons.paid),
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Quick Discount Selector
                      Row(
                        children: [
                          const Text('Discount: ', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          ...[70.0, 75.0, 80.0, 81.0, 85.0].map((d) {
                            final isSel = _discountPercent == d;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(d == 81.0 ? '81% (Standard)' : '${d.toInt()}%'),
                                selected: isSel,
                                selectedColor: const Color(0xFF8B0000),
                                labelStyle: TextStyle(
                                  color: isSel ? Colors.white : Colors.black,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                                onSelected: (_) => setState(() => _discountPercent = d),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search & Filter
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search crackers (e.g. sparklers, rockets)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Category Chips
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: DefaultData.crackerCategories.length,
              itemBuilder: (ctx, i) {
                final cat = DefaultData.crackerCategories[i];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(cat),
                    selectedColor: const Color(0xFF8B0000),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    padding: const EdgeInsets.all(2),
                    onSelected: (selected) {
                      setState(() => _selectedCategory = cat);
                    },
                  ),
                );
              },
            ),
          ),

          const Divider(height: 8),

          // Products List with Stepper
          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(child: Text('No crackers found matching search'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                    itemCount: _filteredProducts.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (ctx, index) {
                      final p = _filteredProducts[index];
                      final qty = _cartQuantities[p.id] ?? 0;
                      final isSelected = qty > 0;

                      return Container(
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFFF8E1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          title: Text(
                            p.name,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14.5,
                            ),
                          ),
                          subtitle: Text(
                            '${p.unit} • MRP: ₹${p.price.toStringAsFixed(0)} (After ${_discountPercent.toInt()}%: ₹${(p.price * (1 - _discountPercent / 100)).toStringAsFixed(0)})',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          trailing: qty == 0
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8B0000),
                                    foregroundColor: Colors.white,
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  onPressed: () => _updateQuantity(p, 1),
                                  child: const Text('+ ADD'),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle, color: Colors.red, size: 26),
                                      onPressed: () => _updateQuantity(p, -1),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        // Quick input dialog
                                        final qtyCtrl = TextEditingController(text: '$qty');
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: Text('Quantity for ${p.name}'),
                                            content: TextField(
                                              controller: qtyCtrl,
                                              keyboardType: TextInputType.number,
                                              autofocus: true,
                                              decoration: const InputDecoration(
                                                labelText: 'Number of units',
                                                border: OutlineInputBorder(),
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(ctx).pop(),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  final val = int.tryParse(qtyCtrl.text.trim()) ?? 0;
                                                  _setDirectQuantity(p, val);
                                                  Navigator.of(ctx).pop();
                                                },
                                                child: const Text('Set'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: const Color(0xFF8B0000), width: 1.2),
                                          borderRadius: BorderRadius.circular(4),
                                          color: Colors.white,
                                        ),
                                        child: Text(
                                          '$qty',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF8B0000),
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle, color: Colors.green, size: 26),
                                      onPressed: () => _updateQuantity(p, 1),
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
