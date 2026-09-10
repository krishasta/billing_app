import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../models/bill.dart';
import '../models/shop_profile.dart';
import '../services/pdf_service.dart';

class BillPreviewScreen extends StatelessWidget {
  final Bill bill;
  final ShopProfile shop;

  const BillPreviewScreen({
    super.key,
    required this.bill,
    required this.shop,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invoice #${bill.id.replaceAll('CRK-', '')}'),
            Text(
              '${bill.customerName} · ₹${bill.grandTotal.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 12, color: Color(0xFFFDE68A)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share via WhatsApp',
            onPressed: () => PdfService.shareBillPdf(bill, shop),
          ),
          IconButton(
            icon: const Icon(Icons.print_rounded),
            tooltip: 'Print Invoice',
            onPressed: () => PdfService.printBillPdf(bill, shop),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                child: OutlinedButton.icon(
                  onPressed: () => PdfService.printBillPdf(bill, shop),
                  icon: const Icon(Icons.print, size: 18),
                  label: const Text('PRINT'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: const Color(0xFF1E130D),
                    side: const BorderSide(color: Color(0xFFEAD8C3), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () => PdfService.shareBillPdf(bill, shop),
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text(
                    'SHARE SOFTCOPY (WHATSAPP)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: PdfPreview(
        build: (format) => PdfService.generateBillPdf(bill: bill, shop: shop),
        initialPageFormat: PdfPageFormat.a4,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
      ),
    );
  }
}
