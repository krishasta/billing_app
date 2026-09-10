import 'package:flutter/material.dart';
import '../models/shop_profile.dart';
import '../services/storage_service.dart';
import '../services/google_sheets_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _shopNameCtrl;
  late TextEditingController _taglineCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _altPhoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _gstCtrl;
  late TextEditingController _upiCtrl;
  late TextEditingController _discountCtrl;
  late TextEditingController _termsCtrl;
  late TextEditingController _sheetUrlCtrl;
  String? _lastSyncTime;
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await StorageService.getShopProfile();
    final sheetUrl = await GoogleSheetsService.getSheetUrl();
    final lastSync = await GoogleSheetsService.getLastSyncTime();

    _shopNameCtrl = TextEditingController(text: profile.shopName);
    _taglineCtrl = TextEditingController(text: profile.tagline);
    _phoneCtrl = TextEditingController(text: profile.phone);
    _altPhoneCtrl = TextEditingController(text: profile.alternatePhone);
    _addressCtrl = TextEditingController(text: profile.address);
    _gstCtrl = TextEditingController(text: profile.gstNumber);
    _upiCtrl = TextEditingController(text: profile.upiId);
    _discountCtrl = TextEditingController(text: profile.defaultDiscountPercent.toString());
    _termsCtrl = TextEditingController(text: profile.termsAndConditions);
    _sheetUrlCtrl = TextEditingController(text: sheetUrl);

    setState(() {
      _lastSyncTime = lastSync;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _taglineCtrl.dispose();
    _phoneCtrl.dispose();
    _altPhoneCtrl.dispose();
    _addressCtrl.dispose();
    _gstCtrl.dispose();
    _upiCtrl.dispose();
    _discountCtrl.dispose();
    _termsCtrl.dispose();
    _sheetUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _triggerSheetSync() async {
    await GoogleSheetsService.saveSheetUrl(_sheetUrlCtrl.text.trim());
    setState(() => _isSyncing = true);

    final result = await GoogleSheetsService.syncProducts();
    final lastSync = await GoogleSheetsService.getLastSyncTime();

    if (!mounted) return;
    setState(() {
      _lastSyncTime = lastSync;
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


  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = ShopProfile(
      shopName: _shopNameCtrl.text.trim(),
      tagline: _taglineCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      alternatePhone: _altPhoneCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      gstNumber: _gstCtrl.text.trim(),
      upiId: _upiCtrl.text.trim(),
      defaultDiscountPercent: double.tryParse(_discountCtrl.text.trim()) ?? 81.0,
      termsAndConditions: _termsCtrl.text.trim(),
    );

    await StorageService.saveShopProfile(updated);
    await GoogleSheetsService.saveSheetUrl(_sheetUrlCtrl.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Shop profile & settings saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF8B1E0F))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Profile & Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_rounded),
            tooltip: 'Save Settings',
            onPressed: _saveProfile,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: _saveProfile,
            icon: const Icon(Icons.save_rounded),
            label: const Text('SAVE ALL SETTINGS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            // 1. Shop Identity Card
            _buildSectionCard(
              title: 'Shop Identity & Branding',
              icon: Icons.storefront_rounded,
              children: [
                TextFormField(
                  controller: _shopNameCtrl,
                  decoration: const InputDecoration(labelText: 'Shop / Brand Name *', prefixIcon: Icon(Icons.business)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _taglineCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tagline / Header Subtitle',
                    hintText: 'e.g. Sivakasi · Since 1994 | Direct Factory Price',
                    prefixIcon: Icon(Icons.subtitles_outlined),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 2. Google Sheet Cloud Sync Card
            _buildSectionCard(
              title: 'Google Sheet Product Sync',
              icon: Icons.cloud_sync_rounded,
              children: [
                TextFormField(
                  controller: _sheetUrlCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Google Apps Script Web App URL',
                    hintText: 'https://script.google.com/macros/s/.../exec',
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                if (_lastSyncTime != null) ...[
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 15, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        'Last Synced: $_lastSyncTime',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isSyncing ? null : _triggerSheetSync,
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync_rounded),
                    label: Text(_isSyncing ? 'Syncing Products...' : 'SYNC PRODUCTS NOW'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 3. Contact & Location Card
            _buildSectionCard(
              title: 'Contact & Sivakasi Address',
              icon: Icons.contact_phone_rounded,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Primary Mobile *',
                          prefixIcon: Icon(Icons.phone_android),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _altPhoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Landline / WhatsApp',
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Shop Full Address & Pincode',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 4. Billing & Payments Card
            _buildSectionCard(
              title: 'Billing, Taxes & UPI',
              icon: Icons.payment_rounded,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _gstCtrl,
                        decoration: const InputDecoration(
                          labelText: 'GSTIN (Optional)',
                          prefixIcon: Icon(Icons.receipt_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _upiCtrl,
                        decoration: const InputDecoration(
                          labelText: 'UPI ID for QR Code',
                          prefixIcon: Icon(Icons.qr_code_2),
                          hintText: '9842011994@upi',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _discountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Default Catalogue Discount (%)',
                    prefixIcon: Icon(Icons.percent),
                    suffixText: '%',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    final numVal = double.tryParse(v.trim());
                    if (numVal == null || numVal < 0 || numVal > 100) return 'Enter 0 to 100';
                    return null;
                  },
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 5. PESO Safety Terms & Conditions Card
            _buildSectionCard(
              title: 'PESO Safety Terms on Invoice PDF',
              icon: Icons.verified_user_rounded,
              children: [
                TextFormField(
                  controller: _termsCtrl,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Terms & Conditions',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );

  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF8B1E0F)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E130D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}
