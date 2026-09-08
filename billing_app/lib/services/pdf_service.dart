import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/bill.dart';
import '../models/shop_profile.dart';

class PdfService {
  static Future<Uint8List> generateBillPdf({
    required Bill bill,
    required ShopProfile shop,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs. ', decimalDigits: 2);

    // Primary brand colors
    const primaryColor = PdfColor.fromInt(0xFF8B0000); // Deep Crimson
    const secondaryColor = PdfColor.fromInt(0xFF2C3E50); // Navy Blue
    const lightGrey = PdfColor.fromInt(0xFFF7F9FA);
    const borderGrey = PdfColor.fromInt(0xFFE2E8F0);
    const highlightGreen = PdfColor.fromInt(0xFF1E7E34);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
            // ==========================================
            // SHOP HEADER
            // ==========================================
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          shop.shopName.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        if (shop.tagline.isNotEmpty) ...[
                          pw.SizedBox(height: 2),
                          pw.Text(
                            shop.tagline,
                            style: const pw.TextStyle(
                              fontSize: 9,
                              color: PdfColors.amber100,
                            ),
                          ),
                        ],
                        pw.SizedBox(height: 4),
                        pw.Text(
                          shop.address,
                          style: const pw.TextStyle(
                            fontSize: 8.5,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Phone: ${shop.phone}${shop.alternatePhone.isNotEmpty ? " / ${shop.alternatePhone}" : ""}',
                          style: const pw.TextStyle(
                            fontSize: 8.5,
                            color: PdfColors.white,
                          ),
                        ),
                        if (shop.gstNumber.isNotEmpty) ...[
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'GST / License: ${shop.gstNumber}',
                            style: const pw.TextStyle(
                              fontSize: 8,
                              color: PdfColors.grey200,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'ESTIMATE / BILL',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          bill.id,
                          style: pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 12),

            // ==========================================
            // CUSTOMER & INVOICE DETAILS
            // ==========================================
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: lightGrey,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: borderGrey),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BILLED TO:',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          bill.customerName.isNotEmpty ? bill.customerName : 'Cash Customer',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: secondaryColor,
                          ),
                        ),
                        if (bill.customerPhone.isNotEmpty)
                          pw.Text(
                            'Mobile: ${bill.customerPhone}',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        if (bill.customerAddress.isNotEmpty)
                          pw.Text(
                            'City / Address: ${bill.customerAddress}',
                            style: const pw.TextStyle(fontSize: 8.5),
                          ),
                      ],
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Date: ${dateFormat.format(bill.date)}',
                        style: const pw.TextStyle(fontSize: 8.5),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Total Items: ${bill.totalItemsCount} (${bill.totalPiecesCount} Pcs)',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 14),

            // ==========================================
            // ITEMS TABLE
            // ==========================================
            pw.Table(
              border: pw.TableBorder.all(color: borderGrey, width: 0.8),
              columnWidths: const {
                0: pw.FlexColumnWidth(0.8), // S.No
                1: pw.FlexColumnWidth(3.8), // Item Name
                2: pw.FlexColumnWidth(1.8), // Category
                3: pw.FlexColumnWidth(1.2), // Qty
                4: pw.FlexColumnWidth(1.6), // Rate (MRP)
                5: pw.FlexColumnWidth(2.0), // Total
              },
              children: [
                // Table Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: secondaryColor),
                  children: [
                    _buildCell('#', isHeader: true, align: pw.TextAlign.center),
                    _buildCell('Crackers Description', isHeader: true),
                    _buildCell('Category', isHeader: true),
                    _buildCell('Qty', isHeader: true, align: pw.TextAlign.center),
                    _buildCell('Rate (MRP)', isHeader: true, align: pw.TextAlign.right),
                    _buildCell('Total', isHeader: true, align: pw.TextAlign.right),
                  ],
                ),
                // Table Rows
                ...bill.items.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final item = entry.value;
                  final isEven = index % 2 == 0;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: isEven ? lightGrey : PdfColors.white,
                    ),
                    children: [
                      _buildCell('$index', align: pw.TextAlign.center),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              item.product.name,
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            if (item.product.subtitle != null && item.product.subtitle!.isNotEmpty)
                              pw.Text(
                                item.product.subtitle!,
                                style: const pw.TextStyle(
                                  fontSize: 7.5,
                                  color: PdfColors.grey700,
                                ),
                              ),
                          ],
                        ),
                      ),
                      _buildCell(item.product.category, fontSize: 8),
                      _buildCell('${item.quantity} ${item.product.unit}',
                          align: pw.TextAlign.center, fontSize: 8.5),
                      _buildCell(currencyFormat.format(item.unitPrice),
                          align: pw.TextAlign.right, fontSize: 8.5),
                      _buildCell(
                        currencyFormat.format(item.totalPrice),
                        align: pw.TextAlign.right,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8.5,
                      ),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 12),

            // ==========================================
            // TOTALS & SUMMARY SECTION
            // ==========================================
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left: Payment & UPI info + Notes
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (shop.upiId.isNotEmpty)
                        pw.Container(
                          padding: const pw.EdgeInsets.all(8),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.amber50,
                            borderRadius: pw.BorderRadius.circular(4),
                            border: pw.Border.all(color: PdfColors.amber300),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Text('UPI Payment: ',
                                  style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                              pw.Text(shop.upiId,
                                  style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.blue800)),
                            ],
                          ),
                        ),
                      if (bill.notes.isNotEmpty) ...[
                        pw.SizedBox(height: 6),
                        pw.Text('Remarks: ${bill.notes}',
                            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800)),
                      ],
                      pw.SizedBox(height: 8),
                      pw.Text(
                        shop.termsAndConditions,
                        style: const pw.TextStyle(fontSize: 6.8, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(width: 16),

                // Right: Price Summary Box
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      color: lightGrey,
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border.all(color: borderGrey),
                    ),
                    child: pw.Column(
                      children: [
                        _buildSummaryRow(
                          'Gross Total (MRP)',
                          currencyFormat.format(bill.subtotal),
                        ),
                        if (bill.discountPercent > 0) ...[
                          pw.SizedBox(height: 4),
                          _buildSummaryRow(
                            'Special Discount (${bill.discountPercent.toStringAsFixed(0)}%)',
                            '- ${currencyFormat.format(bill.discountAmount)}',
                            color: highlightGreen,
                          ),
                        ],
                        pw.Divider(color: borderGrey, height: 12),
                        _buildSummaryRow(
                          'NET PAYABLE',
                          currencyFormat.format(bill.grandTotal),
                          isBold: true,
                          fontSize: 11,
                          color: primaryColor,
                        ),
                        if (bill.advancePaid > 0) ...[
                          pw.SizedBox(height: 4),
                          _buildSummaryRow(
                            'Advance Paid',
                            currencyFormat.format(bill.advancePaid),
                            color: PdfColors.blue800,
                          ),
                          pw.SizedBox(height: 4),
                          _buildSummaryRow(
                            'Balance Due',
                            currencyFormat.format(bill.balanceDue),
                            isBold: true,
                            color: bill.balanceDue > 0 ? primaryColor : highlightGreen,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // ==========================================
            // FOOTER & SIGNATURE
            // ==========================================
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '🎆 Thank you for celebrating with ${shop.shopName}! 🪔',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.Text(
                      'This is a computer generated softcopy invoice.',
                      style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(
                      width: 110,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400, width: 0.8)),
                      ),
                      padding: const pw.EdgeInsets.only(top: 4),
                      child: pw.Text(
                        'Authorized Signatory',
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
    pw.FontWeight fontWeight = pw.FontWeight.normal,
    double fontSize = 8.5,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: fontSize,
          fontWeight: isHeader ? pw.FontWeight.bold : fontWeight,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
      ),
    );
  }

  static pw.Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 9,
    PdfColor color = PdfColors.black,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  static Future<void> shareBillPdf(Bill bill, ShopProfile shop) async {
    final bytes = await generateBillPdf(bill: bill, shop: shop);
    final filename = '${bill.id}_${bill.customerName.replaceAll(RegExp(r'\s+'), '_')}.pdf';
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  static Future<void> printBillPdf(Bill bill, ShopProfile shop) async {
    final bytes = await generateBillPdf(bill: bill, shop: shop);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: bill.id,
    );
  }
}
