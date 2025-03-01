import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart' as sembast_io;
import 'package:sembast_web/sembast_web.dart';
import 'package:account/model/brandItem.dart';
import 'package:account/model/autoTechItem.dart'; // Import AutoTechItem
import 'package:account/database/brandDB.dart'; // Import BrandDB to fetch BrandItem

class AutoTechDB {
  String dbName;

  AutoTechDB({required this.dbName});

  Future<Database> openDatabase() async {
    if (kIsWeb) {
      return await databaseFactoryWeb.openDatabase(dbName);
    } else {
      Directory appDir = await getApplicationDocumentsDirectory();
      String dbLocation = join(appDir.path, dbName);
      return await sembast_io.databaseFactoryIo.openDatabase(dbLocation);
    }
  }

  // ✅ เพิ่ม AutoTechItem เข้า Database
  Future<int> insertAutoTechItem(AutoTechItem item) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('auto_tech');

    int techID = await store.add(db, {
      'Brand_ID': item.brand.Brand_ID, // Store Brand_ID
      'Technology_Name': item.Technology_Name,
      'Release_Year': item.release_Year,
    });

    return techID;
  }
Future<List<AutoTechItem>> loadAllAutoTechItems() async {
  var db = await openDatabase();
  var store = intMapStoreFactory.store('auto_tech');
  var snapshot = await store.find(
    db,
    finder: Finder(sortOrders: [SortOrder('Release_Year', false)]),
  );

  List<AutoTechItem> autoTechItems = [];
  BrandDB brandDB = BrandDB(dbName: 'brandItems.db'); // Create an instance of BrandDB

  for (var record in snapshot) {
    // Fetch the BrandItem using the Brand_ID
    BrandItem? brand = await brandDB.getBrandById(record['Brand_ID'] as int?); // Fetch the brand

    autoTechItems.add(AutoTechItem(
      Tech_ID: record.key as int?, // Cast to int?
      brand: brand ?? BrandItem( // Use the fetched BrandItem or a default one
        Brand_ID: record['Brand_ID'] as int?,
        Brand_Name: 'Unknown', // Default value if brand is not found
        Country: 'Unknown', // Default value if brand is not found
        Founded_Year: 0, // Default value if brand is not found
      ),
      Technology_Name: record['Technology_Name'].toString(),
      release_Year: int.parse(record['Release_Year'].toString()),
    ));
  }

  return autoTechItems;
}

  // ✅ ลบ AutoTechItem ออกจาก Database
  Future<void> deleteAutoTechItem(int techID) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('auto_tech');
    await store.delete(db, finder: Finder(filter: Filter.byKey(techID)));
  }

  // ✅ อัปเดตข้อมูล AutoTechItem
  Future<void> updateAutoTechItem(AutoTechItem item) async {
    var db = await openDatabase();
    var store = intMapStoreFactory.store('auto_tech');

    await store.update(
      db,
      {
        'Brand_ID': item.brand.Brand_ID,
        'Technology_Name': item.Technology_Name,
        'Release_Year': item.release_Year,
      },
      finder: Finder(filter: Filter.byKey(item.Tech_ID)),
    );
  }
}