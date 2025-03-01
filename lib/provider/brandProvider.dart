import 'package:flutter/foundation.dart';
import 'package:account/database/brandDB.dart'; // ใช้ BrandDB แทน AutoTechItemDB
import 'package:account/model/brandItem.dart'; // ใช้ BrandItem แทน AutoTechItem

class BrandProvider with ChangeNotifier {
  List<BrandItem> brandItems = [];

  List<BrandItem> getBrandItems() {
    return brandItems;
  }

  void initData() async {
    var db = BrandDB(dbName: 'brandItems.db'); // เปลี่ยนเป็น BrandDB
    brandItems = await db.loadAllBrandItems(); // ใช้ loadAllBrandItems
    notifyListeners();
  }

  void addBrandItem(BrandItem brandItem) async {
    var db = BrandDB(dbName: 'brandItems.db'); // เปลี่ยนเป็น BrandDB
    await db.insertBrandItem(brandItem); // ใช้ insertBrandItem
    brandItems = await db.loadAllBrandItems(); // ใช้ loadAllBrandItems
    notifyListeners();
  }

  void deleteBrandItem(int brandID) async {
    var db = BrandDB(dbName: 'brandItems.db'); // เปลี่ยนเป็น BrandDB
    await db.deleteBrandItem(brandID); // ใช้ deleteBrandItem
    brandItems = await db.loadAllBrandItems(); // ใช้ loadAllBrandItems
    notifyListeners();
  }

  void updateBrandItem(BrandItem brandItem) async {
    var db = BrandDB(dbName: 'brandItems.db'); // เปลี่ยนเป็น BrandDB
    await db.updateBrandItem(brandItem); // ใช้ updateBrandItem
    brandItems = await db.loadAllBrandItems(); // ใช้ loadAllBrandItems
    notifyListeners();
  }
  
  Future<void> insertDummyData() async {
    var db = BrandDB(dbName: 'brandItems.db');
    await db.insertDummyData(); // เรียกใช้จาก database
    brandItems = await db.loadAllBrandItems(); // ใช้ loadAllBrandItems
    notifyListeners();  // แจ้งให้ listener ทราบว่า data ได้ถูกเพิ่ม
  }

}
