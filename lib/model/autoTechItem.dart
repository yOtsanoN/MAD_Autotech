import 'package:account/model/brandItem.dart';

class AutoTechItem {
  int? Tech_ID;
  BrandItem brand; 
  String Technology_Name;
  int release_Year;

  AutoTechItem({this.Tech_ID, required this.brand, required this.Technology_Name,required this.release_Year});
}
