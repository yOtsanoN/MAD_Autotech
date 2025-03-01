import 'package:account/model/autoTechItem.dart';
import 'package:account/model/brandItem.dart';
import 'package:account/provider/autoTechProvider.dart';
import 'package:account/provider/brandProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final formKey = GlobalKey<FormState>();
  final techController = TextEditingController();
  final yearController = TextEditingController();
  BrandItem? selectedBrand; // ใช้เพื่อเก็บแบรนด์ที่ผู้ใช้เลือก

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          'เพิ่มเทคโนโลยีรถยนต์ไร้คนขับ',
          style: TextStyle(
              fontSize: MediaQuery.of(context).size.width *
                  0.05), // ขนาดฟอนต์จะขึ้นอยู่กับขนาดหน้าจอ
        ),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            // ช่องกรอกชื่อเทคโนโลยี
            TextFormField(
              decoration: InputDecoration(label: const Text('ชื่อเทคโนโลยี')),
              autofocus: true,
              controller: techController,
              validator: (String? value) {
                if (value!.isEmpty) {
                  return "กรุณาป้อนชื่อเทคโนโลยี";
                }
                return null;
              },
            ),
            // ช่องกรอกชื่อแบรนด์
            Consumer<BrandProvider>(
              builder: (context, brandProvider, child) {
                // ดึงรายการแบรนด์จาก provider
                List<BrandItem> brands = brandProvider.brandItems;
                return DropdownButtonFormField<BrandItem>(
                  value: selectedBrand,
                  decoration: InputDecoration(label: const Text('เลือกแบรนด์')),
                  onChanged: (BrandItem? newBrand) {
                    setState(() {
                      selectedBrand = newBrand;
                    });
                  },
                  items: brands.map((BrandItem brand) {
                    return DropdownMenuItem<BrandItem>(
                      value: brand,
                      child: Text(brand.Brand_Name),
                    );
                  }).toList(),
                  validator: (BrandItem? value) {
                    if (value == null) {
                      return "กรุณาเลือกแบรนด์";
                    }
                    return null;
                  },
                );
              },
            ),
            // ช่องกรอกปีที่เปิดตัว
            TextFormField(
              decoration: InputDecoration(label: const Text('ปีที่เปิดตัว')),
              keyboardType: TextInputType.number,
              controller: yearController,
              validator: (String? value) {
                try {
                  int year = int.parse(value!); // ใช้ int สำหรับปีที่เปิดตัว
                  if (year <= 0) {
                    return "กรุณาป้อนปีที่เปิดตัวที่มากกว่า 0";
                  }
                } catch (e) {
                  return "กรุณาป้อนเป็นตัวเลขเท่านั้น";
                }
                return null;
              },
            ),
            // ปุ่มเพิ่มข้อมูล
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // ใช้ Provider เพื่อเพิ่มข้อมูล
                  var provider =
                      Provider.of<AutoTechProvider>(context, listen: false);

                  // ตรวจสอบว่าเลือกแบรนด์แล้วหรือยัง
                  if (selectedBrand != null) {
                    // สร้าง AutoTechItem ใหม่
                    AutoTechItem item = AutoTechItem(
                      Technology_Name: techController.text,
                      brand: selectedBrand!, // ใช้ selectedBrand ที่ถูกเลือก
                      release_Year: int.parse(yearController.text),
                    );

                    // เพิ่มข้อมูลใน provider
                    provider.addAutoTechItem(item);

                    // ปิดหน้าจอ
                    Navigator.pop(context);
                  } else {
                    // แจ้งเตือนหากไม่มีการเลือกแบรนด์
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('กรุณาเลือกแบรนด์')),
                    );
                  }
                }
              },
              child: const Text('เพิ่มข้อมูล'),
            ),
          ],
        ),
      ),
    );
  }
}
