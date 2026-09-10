import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/default_data.dart';
import '../services/storage_service.dart';
import '../services/google_sheets_service.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  double _defaultDiscount = 81.0;
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _syncFromGoogleSheet() async {
    setState(() => _isSyncing = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Syncing products from Google Sheet...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    final result = await GoogleSheetsService.syncProducts();
    if (!mounted) return;

    setState(() {
      _products = result.products;
      _isSyncing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green.shade700 : Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final list = await StorageService.getProducts();
    final profile = await StorageService.getShopProfile();
    setState(() {
      _products = list;
      _defaultDiscount = profile.defaultDiscountPercent;
      _isLoading = false;
    });
  }

  List<Product> get _filteredProducts {
    return _products.where((p) {
      final matchesCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (p.subtitle != null && p.subtitle!.toLowerCase().contains(_searchQuery.toLowerCase())) ||
          p.category.toLowerCase().contains(_searchQuery.toLowerCase());
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

  void _showAddEditProductDialog([Product? product]) {
    final isEditing = product != null;
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final subtitleCtrl = TextEditingController(text: product?.subtitle ?? '');
    final priceCtrl = TextEditingController(text: product != null ? product.price.toStringAsFixed(2) : '');
    final unitCtrl = TextEditingController(text: product?.unit ?? '1 PKT');
    String selectedCategory = product?.category ?? 'Sparklers';

    final categories = DefaultData.crackerCategories.where((c) => c != 'All').toList();
    if (!categories.contains(selectedCategory)) {
      categories.add(selectedCategory);
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit Cracker Product' : 'Add New Cracker Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Item Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedCategory = val);
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Catalogue MRP *',
                          prefixText: '₹ ',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: unitCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: subtitleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Notes / Subtitle (Optional)',
                    hintText: 'e.g. 10 Pcs / Net: ₹15',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                final unit = unitCtrl.text.trim().isEmpty ? '1 PKT' : unitCtrl.text.trim();
                final subtitle = subtitleCtrl.text.trim().isEmpty ? null : subtitleCtrl.text.trim();

                if (name.isEmpty || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter valid product name and MRP price'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (isEditing) {
                  final updated = product.copyWith(
                    name: name,
                    category: selectedCategory,
                    price: price,
                    unit: unit,
                    subtitle: subtitle,
                  );
                  await StorageService.updateProduct(updated);
                } else {
                  final newProd = Product(
                    id: 'RC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                    name: name,
                    category: selectedCategory,
                    price: price,
                    unit: unit,
                    subtitle: subtitle,
                  );
                  await StorageService.addProduct(newProd);
                }

                if (ctx.mounted) Navigator.of(ctx).pop();
                _loadProducts();
              },
              child: Text(isEditing ? 'Update' : 'Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to remove "${product.name}" from your catalog?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              await StorageService.deleteProduct(product.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
              _loadProducts();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = DefaultData.crackerCategories;
    final filtered = _filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Price Catalog & Rates'),
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.cloud_sync_rounded),
            tooltip: 'Sync from Google Sheet',
            onPressed: _isSyncing ? null : _syncFromGoogleSheet,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset to Factory Defaults',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reset Catalog to Defaults?'),
                  content: const Text('This will reload the official 2026 Sivakasi cracker catalog price list.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () async {
                        await StorageService.resetDefaultProducts();
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        _loadProducts();
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditProductDialog(),
        backgroundColor: const Color(0xFF8B1E0F),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('ADD CRACKER', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B1E0F)))
          : RefreshIndicator(
              color: const Color(0xFF8B1E0F),
              onRefresh: _syncFromGoogleSheet,
              child: Column(
                children: [
                  // Google Sheet Quick Sync Banner
                  Container(
                    margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF93C5FD)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_done_rounded, size: 18, color: Color(0xFF1D4ED8)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Connected to Google Sheet · ${_products.length} Products loaded',
                            style: const TextStyle(
                              color: Color(0xFF1E40AF),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _isSyncing ? null : _syncFromGoogleSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1D4ED8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'SYNC NOW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Top Info & Search Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search ${_products.length} cracker items...',

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

                // Category Chips
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

                // Products Count Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Showing ${filtered.length} of ${_products.length} items',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF786A5E), fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_defaultDiscount.toStringAsFixed(0)}% Discount Rates',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Product Cards List
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'No cracker products found.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, idx) {
                            final p = filtered[idx];
                            final netPrice = p.price * (1 - _defaultDiscount / 100);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFFFEF3C7),
                                  child: Text(
                                    _getCategoryEmoji(p.category),
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                                title: Text(
                                  p.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Text(
                                          'Net: ₹${netPrice.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Color(0xFF8B1E0F),
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'MRP: ₹${p.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            decoration: TextDecoration.lineThrough,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '/ ${p.unit}',
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF786A5E)),
                                        ),
                                      ],
                                    ),
                                    if (p.subtitle != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        p.subtitle!,
                                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF1D4ED8)),
                                      onPressed: () => _showAddEditProductDialog(p),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                      onPressed: () => _confirmDelete(p),
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
          ),
    );
  }
}

