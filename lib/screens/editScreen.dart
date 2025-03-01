import 'package:account/model/autoTechItem.dart';
import 'package:account/model/brandItem.dart';
import 'package:account/provider/autoTechProvider.dart';
import 'package:account/provider/brandProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditScreen extends StatefulWidget {
  final AutoTechItem item; // ใช้ AutoTechItem เท่านั้น

  const EditScreen({super.key, required this.item});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final formKey = GlobalKey<FormState>();
  final techController = TextEditingController();
  final yearController = TextEditingController();
  BrandItem? selectedBrand;

  @override
  void initState() {
    super.initState();
    techController.text = widget.item.Technology_Name;
    yearController.text = widget.item.release_Year.toString();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      var brands = Provider.of<BrandProvider>(context, listen: false).brandItems;
      setState(() {
        selectedBrand = brands.firstWhere(
          (brand) => brand.Brand_ID == widget.item.brand.Brand_ID,
          orElse: () => brands.isNotEmpty
              ? brands.first
              : BrandItem(
                  Brand_ID: 0,
                  Brand_Name: 'Unknown',
                  Country: 'Unknown',
                  Founded_Year: 0,
                ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Edit Technology'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ช่องกรอกชื่อเทคโนโลยี
                TextFormField(
                  decoration: const InputDecoration(labelText: 'ชื่อเทคโนโลยี'),
                  autofocus: true,
                  controller: techController,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return "กรุณาป้อนชื่อเทคโนโลยี";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Dropdown เลือกแบรนด์
                Consumer<BrandProvider>(
                  builder: (context, brandProvider, child) {
                    List<BrandItem> brands = brandProvider.brandItems;

                    return DropdownButtonFormField<BrandItem>(
                      value: brands.contains(selectedBrand) ? selectedBrand : null,
                      decoration: const InputDecoration(labelText: 'เลือกแบรนด์'),
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
                const SizedBox(height: 16),
                // ช่องกรอกปีที่เปิดตัว
                TextFormField(
                  decoration: const InputDecoration(labelText: 'ปีที่เปิดตัว'),
                  keyboardType: TextInputType.number,
                  controller: yearController,
                  validator: (String? value) {
                    try {
                      int year = int.parse(value!);
                      if (year <= 0) {
                        return "กรุณาป้อนปีที่มากกว่า 0";
                      }
                    } catch (e) {
                      return "กรุณาป้อนเป็นตัวเลขเท่านั้น";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // ปุ่มบันทึกการแก้ไข
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        var provider =
                            Provider.of<AutoTechProvider>(context, listen: false);

                        if (selectedBrand != null) {
                          AutoTechItem updatedItem = AutoTechItem(
                            Tech_ID: widget.item.Tech_ID,
                            Technology_Name: techController.text,
                            brand: selectedBrand!,
                            release_Year: int.parse(yearController.text),
                          );

                          provider.updateAutoTechItem(updatedItem);

                          // ปิดหน้าจอ
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('กรุณาเลือกแบรนด์')),
                          );
                        }
                      }
                    },
                    child: const Text('บันทึกการแก้ไข'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
