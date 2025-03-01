import 'dart:io';
import 'package:flutter/foundation.dart'
    show kIsWeb; // ตรวจสอบว่าเป็น Web หรือไม่
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart' as sembast_io;
import 'package:sembast_web/sembast_web.dart'; // ใช้เฉพาะ Web
import 'package:account/model/brandItem.dart'; // Import brandItem

class BrandDB {
  String dbName;

  BrandDB({required this.dbName});

  Future<Database> openDatabase() async {
    if (kIsWeb) {
      return await databaseFactoryWeb.openDatabase(dbName);
    } else {
      Directory appDir = await getApplicationDocumentsDirectory();
      String dbLocation = join(appDir.path, dbName);
      return await sembast_io.databaseFactoryIo.openDatabase(dbLocation);
    }
  }

  // ✅ เพิ่ม BrandItem เข้า Database
  Future<int> insertBrandItem(BrandItem item) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('brands');

    int brandID = await store.add(db, {
      'Brand_Name': item.Brand_Name,
      'Country': item.Country,
      'Founded_Year': item.Founded_Year,
    });

    return brandID;
  }

  // ✅ โหลดข้อมูล BrandItem ทั้งหมด
  Future<List<BrandItem>> loadAllBrandItems() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('brands');
    var snapshot = await store.find(
      db,
      finder: Finder(sortOrders: [SortOrder('Founded_Year', false)]),
    );

    List<BrandItem> brandItems = snapshot.map((record) {
      return BrandItem(
        Brand_ID: record.key,
        Brand_Name: record['Brand_Name'].toString(),
        Country: record['Country'].toString(),
        Founded_Year: int.parse(record['Founded_Year'].toString()),
      );
    }).toList();

    return brandItems;
  }

  // ✅ ลบ BrandItem ออกจาก Database
  Future<void> deleteBrandItem(int brandID) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('brands');
    await store.delete(db, finder: Finder(filter: Filter.byKey(brandID)));
  }

  // ✅ อัปเดตข้อมูล BrandItem
  Future<void> updateBrandItem(BrandItem item) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('brands');

    await store.update(
      db,
      {
        'Brand_Name': item.Brand_Name,
        'Country': item.Country,
        'Founded_Year': item.Founded_Year,
      },
      finder: Finder(filter: Filter.byKey(item.Brand_ID)),
    );
  }

  Future<void> insertDummyData() async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('brands');

    await store.add(
        db, {'Brand_Name': 'Ford', 'Founded_Year': 1903, 'Country': 'USA'});

    await store.add(
        db, {'Brand_Name': 'Tesla', 'Founded_Year': 2003, 'Country': 'USA'});

    await store.add(
        db, {'Brand_Name': 'Audi', 'Founded_Year': 1909, 'Country': 'Germany'});
  }

// Add this method to your BrandDB class
  Future<BrandItem?> getBrandById(int? brandID) async {
    if (brandID == null) return null; // Return null if the ID is null

    var db = await openDatabase();
    var store = intMapStoreFactory.store('brands');

    // Find the record by key (brandID)
    var record = await store.record(brandID).get(db);

    if (record != null) {
      return BrandItem(
        Brand_ID: brandID,
        Brand_Name: record['Brand_Name'].toString(),
        Country: record['Country'].toString(),
        Founded_Year: int.parse(record['Founded_Year'].toString()),
      );
    }

    return null; // Return null if no record is found
  }
}
