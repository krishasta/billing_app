import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/bill.dart';
import '../models/shop_profile.dart';
import 'default_data.dart';

class StorageService {
  static const String _keyProducts = 'gopi_crackers_products_v4';
  static const String _keyBills = 'gopi_crackers_bills_v4';
  static const String _keyShopProfile = 'gopi_crackers_shop_profile_v4';
  static const String _keyBillCounter = 'gopi_crackers_bill_counter_v4';

  // ----------------------------------------------------
  // PRODUCTS
  // ----------------------------------------------------
  static Future<List<Product>> getProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyProducts);
    if (data == null || data.isEmpty) {
      // First time initialization with preloaded catalog
      final defaults = DefaultData.defaultProducts;
      await saveProducts(defaults);
      return defaults;
    }
    try {
      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      return DefaultData.defaultProducts;
    }
  }

  static Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = products.map((e) => e.toJson()).toList();
    await prefs.setString(_keyProducts, jsonEncode(jsonList));
  }

  static Future<void> addProduct(Product product) async {
    final list = await getProducts();
    list.insert(0, product);
    await saveProducts(list);
  }

  static Future<void> updateProduct(Product product) async {
    final list = await getProducts();
    final idx = list.indexWhere((p) => p.id == product.id);
    if (idx != -1) {
      list[idx] = product;
      await saveProducts(list);
    }
  }

  static Future<void> deleteProduct(String id) async {
    final list = await getProducts();
    list.removeWhere((p) => p.id == id);
    await saveProducts(list);
  }

  static Future<void> resetDefaultProducts() async {
    await saveProducts(DefaultData.defaultProducts);
  }

  // ----------------------------------------------------
  // BILLS
  // ----------------------------------------------------
  static Future<List<Bill>> getBills() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyBills);
    if (data == null || data.isEmpty) return [];
    try {
      final List<dynamic> jsonList = jsonDecode(data);
      final list = jsonList.map((e) => Bill.fromJson(e as Map<String, dynamic>)).toList();
      // Sort newest first
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveBill(Bill bill) async {
    final list = await getBills();
    final idx = list.indexWhere((b) => b.id == bill.id);
    if (idx != -1) {
      list[idx] = bill;
    } else {
      list.insert(0, bill);
    }
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((e) => e.toJson()).toList();
    await prefs.setString(_keyBills, jsonEncode(jsonList));
  }

  static Future<void> deleteBill(String id) async {
    final list = await getBills();
    list.removeWhere((b) => b.id == id);
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((e) => e.toJson()).toList();
    await prefs.setString(_keyBills, jsonEncode(jsonList));
  }

  static Future<String> generateNextBillId() async {
    final prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt(_keyBillCounter) ?? 1000;
    count++;
    await prefs.setInt(_keyBillCounter, count);
    return 'CRK-$count';
  }

  // ----------------------------------------------------
  // SHOP PROFILE
  // ----------------------------------------------------
  static Future<ShopProfile> getShopProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_keyShopProfile);
    if (data == null || data.isEmpty) {
      final defaults = DefaultData.defaultShopProfile;
      await saveShopProfile(defaults);
      return defaults;
    }
    try {
      return ShopProfile.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (e) {
      return DefaultData.defaultShopProfile;
    }
  }

  static Future<void> saveShopProfile(ShopProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyShopProfile, jsonEncode(profile.toJson()));
  }
}
