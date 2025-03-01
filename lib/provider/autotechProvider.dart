import 'package:flutter/foundation.dart';
import 'package:account/database/autoTechDB.dart';
import 'package:account/model/autoTechItem.dart';

class AutoTechProvider with ChangeNotifier {
  List<AutoTechItem> techItems = [];
  final AutoTechDB db = AutoTechDB(dbName: 'autoTechItems.db'); // Ensure this is AutoTechDB

  List<AutoTechItem> getTechItems() {
    return techItems;
  }

  Future<void> initData() async {
    techItems = await db.loadAllAutoTechItems();
    notifyListeners();
  }

  Future<void> addAutoTechItem(AutoTechItem techItem) async {
    await db.insertAutoTechItem(techItem);
    techItems = await db.loadAllAutoTechItems();
    notifyListeners();
  }

  Future<void> deleteAutoTechItem(int techID) async {
    await db.deleteAutoTechItem(techID);
    techItems = await db.loadAllAutoTechItems();
    notifyListeners();
  }

  Future<void> updateAutoTechItem(AutoTechItem techItem) async {
    await db.updateAutoTechItem(techItem);
    techItems = await db.loadAllAutoTechItems();
    notifyListeners();
  }
}