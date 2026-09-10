import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bill.dart';
import '../models/shop_profile.dart';
import '../services/storage_service.dart';
import '../services/google_sheets_service.dart';
import 'new_bill_screen.dart';
import 'history_screen.dart';
import 'product_list_screen.dart';
import 'settings_screen.dart';
import 'bill_preview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ShopProfile? _profile;
  List<Bill> _recentBills = [];
  int _totalProductCount = 0;
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _silentGoogleSheetSync();
  }

  Future<void> _silentGoogleSheetSync() async {
    final result = await GoogleSheetsService.syncProducts();
    if (mounted && result.success) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final prof = await StorageService.getShopProfile();
    final bills = await StorageService.getBills();
    final products = await StorageService.getProducts();
    if (!mounted) return;
    setState(() {
      _profile = prof;
      _recentBills = bills.take(5).toList();
      _totalProductCount = products.length;
      _isLoading = false;
    });
  }

  Future<void> _manualSync() async {
    setState(() => _isSyncing = true);
    final result = await GoogleSheetsService.syncProducts();
    if (!mounted) return;
    await _loadData();
    if (!mounted) return;
    setState(() => _isSyncing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green.shade700 : Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF8B1E0F)),
        ),
      );
    }

    final shop = _profile!;
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Text('🪔', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.shopName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'SIVAKASI · DIRECT FACTORY BILLING',
                    style: TextStyle(fontSize: 10, letterSpacing: 0.8, color: Colors.amberAccent),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.cloud_sync_rounded),
            tooltip: 'Sync Products from Google Sheet',
            onPressed: _isSyncing ? null : _manualSync,
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Shop Settings',
            onPressed: () async {
              final updated = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              if (updated == true) _loadData();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF8B1E0F),
        onRefresh: _manualSync,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
            // Top Festive Announcement Ticker (Matches fire-crackers web app)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF281810),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Text('✨', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Diwali 2026 Live · 81% Flat Catalogue Discount · Instant PDF & WhatsApp',
                      style: TextStyle(
                        color: Color(0xFFFDE68A),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text('🔥', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),

            // Top Festive Banner Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF7A1507),
                    Color(0xFF9E1B1B),
                    Color(0xFFD97706),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B1E0F).withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded, color: Colors.greenAccent, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'PESO Safe · 100% Offline',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${shop.defaultDiscountPercent.toStringAsFixed(0)}% OFF',
                          style: const TextStyle(
                            color: Color(0xFF92400E),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    shop.shopName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.4,
                    ),
                  ),
                  if (shop.tagline.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      shop.tagline,
                      style: const TextStyle(color: Color(0xFFFFE4D6), fontSize: 12.5),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.phone_in_talk_rounded, color: Color(0xFFFCD34D), size: 15),
                        const SizedBox(width: 6),
                        Text(
                          shop.phone,
                          style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                        if (shop.upiId.isNotEmpty) ...[
                          const SizedBox(width: 14),
                          const Icon(Icons.qr_code_2_rounded, color: Color(0xFFFCD34D), size: 15),
                          const SizedBox(width: 6),
                          Text(
                            shop.upiId,
                            style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick Stats Strip
            Row(
              children: [
                _buildStatBadge(
                  label: 'Items in Catalog',
                  value: '$_totalProductCount',
                  icon: Icons.inventory_2_outlined,
                  color: const Color(0xFFD97706),
                ),
                const SizedBox(width: 10),
                _buildStatBadge(
                  label: 'Default Discount',
                  value: '${shop.defaultDiscountPercent.toStringAsFixed(0)}%',
                  icon: Icons.local_offer_outlined,
                  color: const Color(0xFF8B1E0F),
                ),
                const SizedBox(width: 10),
                _buildStatBadge(
                  label: 'Recent Bills',
                  value: '${_recentBills.length}',
                  icon: Icons.receipt_long_outlined,
                  color: const Color(0xFF047857),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // HERO ACTION: CREATE NEW BILL
            InkWell(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NewBillScreen()),
                );
                _loadData();
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B1E0F), Color(0xFFB91C1C)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B1E0F).withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'CREATE NEW BILL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 6),
                              Text('🚀', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Select crackers, auto-calculate 81% net & export PDF',
                            style: TextStyle(color: Color(0xFFFFECE0), fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // 2-GRID ACTION TILES
            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    title: 'Price Catalog',
                    subtitle: '$_totalProductCount Cracker Items',
                    icon: Icons.category_rounded,
                    color: const Color(0xFFD97706),
                    badge: 'MRP / Net',
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProductListScreen()),
                      );
                      _loadData();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionTile(
                    title: 'Bill History',
                    subtitle: 'View & Re-share Invoices',
                    icon: Icons.history_edu_rounded,
                    color: const Color(0xFF1D4ED8),
                    badge: 'Reports',
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      );
                      _loadData();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // RECENT INVOICES SECTION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text(
                      'Recent Invoices',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E130D),
                      ),
                    ),
                    SizedBox(width: 6),
                    Text('🧾', style: TextStyle(fontSize: 14)),
                  ],
                ),
                if (_recentBills.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    ),
                    icon: const Text('View All', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    label: const Icon(Icons.chevron_right, size: 18),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF8B1E0F),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            if (_recentBills.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEAD8C3)),
                ),
                child: const Column(
                  children: [
                    Text('🪔', style: TextStyle(fontSize: 40)),
                    SizedBox(height: 10),
                    Text(
                      'No Bills Generated Yet',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF281810),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap "Create New Bill" to generate your first Diwali customer invoice.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xFF786A5E)),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(_recentBills.length, (i) {
                final b = _recentBills[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(0xFFFEF3C7),
                          child: Text(
                            b.customerName.isNotEmpty ? b.customerName[0].toUpperCase() : 'C',
                            style: const TextStyle(
                              color: Color(0xFF92400E),
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
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
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
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
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF786A5E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${b.items.length} items (${b.totalPiecesCount} pcs) • ${b.customerPhone.isNotEmpty ? b.customerPhone : "Direct Cash"}',
                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF6E5E52)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('dd MMM, hh:mm a').format(b.date),
                                style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currencyFormat.format(b.grandTotal),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF8B1E0F),
                              ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BillPreviewScreen(bill: b, shop: shop),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B1E0F).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.picture_as_pdf, size: 12, color: Color(0xFF8B1E0F)),
                                    SizedBox(width: 4),
                                    Text(
                                      'PDF',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF8B1E0F),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEAD8C3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF786A5E),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String badge,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEAD8C3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.12),
                  radius: 18,
                  child: Icon(icon, color: color, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF1E130D),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Color(0xFF786A5E)),
            ),
          ],
        ),
      ),
    );
  }
}
