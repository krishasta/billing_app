import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bill.dart';
import '../models/shop_profile.dart';
import '../services/pdf_service.dart';
import '../services/storage_service.dart';
import 'bill_preview_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Bill> _bills = [];
  ShopProfile? _shopProfile;
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    setState(() => _isLoading = true);
    final bills = await StorageService.getBills();
    final profile = await StorageService.getShopProfile();
    setState(() {
      _bills = bills;
      _shopProfile = profile;
      _isLoading = false;
    });
  }

  List<Bill> get _filteredBills {
    if (_searchQuery.isEmpty) return _bills;
    final q = _searchQuery.toLowerCase();
    return _bills.where((b) {
      return b.id.toLowerCase().contains(q) ||
          b.customerName.toLowerCase().contains(q) ||
          b.customerPhone.toLowerCase().contains(q);
    }).toList();
  }

  double get _totalSales => _bills.fold(0.0, (sum, b) => sum + b.grandTotal);

  void _confirmDelete(Bill bill) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Bill'),
        content: Text('Delete invoice #${bill.id} for ${bill.customerName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              await StorageService.deleteBill(bill.id);
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
              }
              if (mounted) {
                _loadBills();
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing History & Reports'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top Summary Card
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B0000), Color(0xFFB71C1C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('TOTAL INVOICES',
                              style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('${_bills.length}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(width: 1, height: 40, color: Colors.white30),
                      Column(
                        children: [
                          const Text('TOTAL BILLING VALUE',
                              style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('₹${_totalSales.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  color: Colors.amberAccent, fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by invoice #, customer name, or phone...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),

                const SizedBox(height: 8),

                // Invoices List
                Expanded(
                  child: _filteredBills.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                              const SizedBox(height: 12),
                              const Text('No bills found',
                                  style: TextStyle(fontSize: 16, color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          itemCount: _filteredBills.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (ctx, index) {
                            final b = _filteredBills[index];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () {
                                  if (_shopProfile != null) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => BillPreviewScreen(
                                          bill: b,
                                          shop: _shopProfile!,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF3E0),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              b.id,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF8B0000),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '₹${b.grandTotal.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF8B0000),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        b.customerName,
                                        style: const TextStyle(
                                            fontSize: 15, fontWeight: FontWeight.bold),
                                      ),
                                      if (b.customerPhone.isNotEmpty)
                                        Text(
                                          'Phone: ${b.customerPhone}',
                                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                                        ),
                                      const Divider(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            dateFormat.format(b.date),
                                            style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.share,
                                                    size: 20, color: Color(0xFF25D366)),
                                                tooltip: 'Share Softcopy',
                                                onPressed: () {
                                                  if (_shopProfile != null) {
                                                    PdfService.shareBillPdf(b, _shopProfile!);
                                                  }
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline,
                                                    size: 20, color: Colors.redAccent),
                                                tooltip: 'Delete Bill',
                                                onPressed: () => _confirmDelete(b),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
