import 'package:flutter/material.dart';
import '../models/shop_profile.dart';
import '../services/storage_service.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await StorageService.getShopProfile();
    _shopNameCtrl = TextEditingController(text: profile.shopName);
    _taglineCtrl = TextEditingController(text: profile.tagline);
    _phoneCtrl = TextEditingController(text: profile.phone);
    _altPhoneCtrl = TextEditingController(text: profile.alternatePhone);
    _addressCtrl = TextEditingController(text: profile.address);
    _gstCtrl = TextEditingController(text: profile.gstNumber);
    _upiCtrl = TextEditingController(text: profile.upiId);
    _discountCtrl = TextEditingController(text: profile.defaultDiscountPercent.toString());
    _termsCtrl = TextEditingController(text: profile.termsAndConditions);
    setState(() => _isLoading = false);
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
    super.dispose();
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
      defaultDiscountPercent: double.tryParse(_discountCtrl.text.trim()) ?? 70.0,
      termsAndConditions: _termsCtrl.text.trim(),
    );

    await StorageService.saveShopProfile(updated);
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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Profile & Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save Settings',
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Business Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.storefront, color: Colors.deepOrange),
                        SizedBox(width: 8),
                        Text(
                          'Business Information',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    TextFormField(
                      controller: _shopNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Company / Shop Name *',
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Please enter shop name' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _taglineCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tagline / Slogan',
                        prefixIcon: Icon(Icons.subtitles),
                        border: OutlineInputBorder(),
                        hintText: 'e.g. Wholesale Fireworks Specialist',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _addressCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Shop Address',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Primary Phone *',
                              prefixIcon: Icon(Icons.phone),
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _altPhoneCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Alternate Phone',
                              prefixIcon: Icon(Icons.phone_android),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _gstCtrl,
                      decoration: const InputDecoration(
                        labelText: 'GSTIN / License Number',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Billing & Payment Settings
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.payments, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Billing & Payment Setup',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    TextFormField(
                      controller: _upiCtrl,
                      decoration: const InputDecoration(
                        labelText: 'UPI ID (For Customer Payments)',
                        prefixIcon: Icon(Icons.qr_code_2),
                        border: OutlineInputBorder(),
                        hintText: 'e.g. mobilenumber@upi or shop@okaxis',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _discountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Default Festival Discount %',
                        prefixIcon: Icon(Icons.percent),
                        border: OutlineInputBorder(),
                        suffixText: '%',
                        helperText: 'Common crackers discount (e.g. 70%) applied to new bills',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter discount %';
                        final num = double.tryParse(v);
                        if (num == null || num < 0 || num > 100) return 'Enter 0 to 100';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Terms & Conditions
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.article, color: Colors.indigo),
                        SizedBox(width: 8),
                        Text(
                          'Terms, Conditions & Safety',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    TextFormField(
                      controller: _termsCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Invoice Footer Notes',
                        border: OutlineInputBorder(),
                        hintText: 'Terms printed at the bottom of the bill...',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              label: const Text('SAVE ALL SETTINGS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: const Color(0xFF8B0000),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
