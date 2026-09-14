import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import 'storage_service.dart';

class GoogleSheetsService {
  static const String _prefKeySheetUrl = 'gopi_crackers_sheet_url_v1';
  static const String _prefKeyLastSync = 'gopi_crackers_last_sync_v1';

  // Default Apps Script Web App URL
  static const String defaultWebAppUrl =
      'https://script.google.com/macros/s/AKfycbz9eqqXaaBaDKZqwjW0r_6cIAwe872MsgDmuPKKaKj8uEXhwmkhOb4xxSPLYLbVt_EX/exec';

  /// Get the configured Google Sheet / Web App URL
  static Future<String> getSheetUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKeySheetUrl) ?? defaultWebAppUrl;
  }

  /// Save custom Google Sheet / Web App URL
  static Future<void> saveSheetUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeySheetUrl, url.trim());
  }

  /// Get formatted timestamp of last successful sync
  static Future<String?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefKeyLastSync);
  }

  /// Fetches products from Google Sheet and saves them to local storage
  static Future<SyncResult> syncProducts() async {
    try {
      final url = await getSheetUrl();
      if (url.isEmpty) {
        return SyncResult(
          success: false,
          message: 'Sheet URL is empty. Please set a valid Apps Script URL.',
          products: await StorageService.getProducts(),
        );
      }

      final uri = Uri.parse(url);
      final response = await http.get(uri).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic> && decoded.containsKey('error')) {
          return SyncResult(
            success: false,
            message: 'Sheet Error: ${decoded['error']}',
            products: await StorageService.getProducts(),
          );
        }

        List<dynamic> jsonList;
        if (decoded is List) {
          jsonList = decoded;
        } else if (decoded is Map<String, dynamic> && decoded.containsKey('products')) {
          jsonList = decoded['products'] as List;
        } else {
          throw Exception('Unexpected data format received from Sheet');
        }

        final List<Product> remoteProducts = [];
        for (var item in jsonList) {
          if (item is Map<String, dynamic>) {
            final id = item['id']?.toString().trim() ?? '';
            final name = item['name']?.toString().trim() ?? '';
            if (id.isEmpty && name.isEmpty) continue;

            final category = item['category']?.toString().trim() ?? 'General';
            final priceRaw = item['price'];
            double price = 0.0;
            if (priceRaw is num) {
              price = priceRaw.toDouble();
            } else if (priceRaw is String) {
              price = double.tryParse(priceRaw.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
            }

            final unit = item['unit']?.toString().trim() ?? 'Box';
            final subtitle = item['subtitle']?.toString().trim();

            remoteProducts.add(
              Product(
                id: id.isNotEmpty ? id : 'PRD-${remoteProducts.length + 1}',
                name: name.isNotEmpty ? name : 'Product ${remoteProducts.length + 1}',
                category: category.isNotEmpty ? category : 'General',
                price: price,
                unit: unit.isNotEmpty ? unit : 'Box',
                subtitle: subtitle != null && subtitle.isNotEmpty ? subtitle : null,
              ),
            );
          }
        }

        if (remoteProducts.isEmpty) {
          return SyncResult(
            success: false,
            message: 'No product rows found in Google Sheet.',
            products: await StorageService.getProducts(),
          );
        }

        // Save downloaded products locally so the app works offline
        await StorageService.saveProducts(remoteProducts);

        final nowStr = DateTime.now().toLocal().toString().split('.')[0];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefKeyLastSync, nowStr);

        return SyncResult(
          success: true,
          message: 'Successfully synced ${remoteProducts.length} products!',
          products: remoteProducts,
        );
      } else {
        return SyncResult(
          success: false,
          message: 'Failed to connect: HTTP status ${response.statusCode}',
          products: await StorageService.getProducts(),
        );
      }
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Sync error: $e',
        products: await StorageService.getProducts(),
      );
    }
  }
}

class SyncResult {
  final bool success;
  final String message;
  final List<Product> products;

  SyncResult({
    required this.success,
    required this.message,
    required this.products,
  });
}
