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
        title: const Text('Delete Invoice'),
        content: Text('Delete invoice #${bill.id} for ${bill.customerName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              await StorageService.deleteBill(bill.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
              _loadBills();
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
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final filtered = _filteredBills;
    final avgBill = _bills.isEmpty ? 0.0 : _totalSales / _bills.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing History & Invoices'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B1E0F)))
          : Column(
              children: [
                // Top Summary Card
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7A1507), Color(0xFF9E1B1B), Color(0xFFD97706)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8B1E0F).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TOTAL TURNOVER',
                              style: TextStyle(
                                color: Color(0xFFFDE68A),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormat.format(_totalSales),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 36, width: 1, color: Colors.white24),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_bills.length} Invoices Generated',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Avg: ${currencyFormat.format(avgBill)}',
                                style: const TextStyle(color: Color(0xFFFFE4D6), fontSize: 11.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search by Customer, Mobile, or Bill No...',
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

                // Bills List
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(
                                _searchQuery.isEmpty ? 'No billing history yet.' : 'No invoices match "$_searchQuery"',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, idx) {
                            final b = filtered[idx];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: const Color(0xFFFEF3C7),
                                          child: Text(
                                            b.customerName.isNotEmpty ? b.customerName[0].toUpperCase() : 'C',
                                            style: const TextStyle(
                                              color: Color(0xFF92400E),
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      b.customerName,
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFF3ECE0),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      '#${b.id.replaceAll('CRK-', '')}',
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF786A5E),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${b.items.length} items (${b.totalPiecesCount} pcs) • ${b.customerPhone.isNotEmpty ? b.customerPhone : "No Phone"}',
                                                style: const TextStyle(fontSize: 12, color: Color(0xFF6E5E52)),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                dateFormat.format(b.date),
                                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              currencyFormat.format(b.grandTotal),
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF8B1E0F),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '(${b.discountPercent.toStringAsFixed(0)}% Off)',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.share, size: 18, color: Color(0xFF25D366)),
                                              tooltip: 'Share via WhatsApp',
                                              onPressed: () {
                                                if (_shopProfile != null) {
                                                  PdfService.shareBillPdf(b, _shopProfile!);
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.picture_as_pdf, size: 18, color: Color(0xFF8B1E0F)),
                                              tooltip: 'Preview PDF',
                                              onPressed: () {
                                                if (_shopProfile != null) {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) => BillPreviewScreen(bill: b, shop: _shopProfile!),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
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
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
