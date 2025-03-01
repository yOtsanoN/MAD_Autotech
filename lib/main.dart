import 'package:account/model/brandItem.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:account/model/autoTechItem.dart';
import 'package:account/provider/autoTechProvider.dart';
import 'package:account/provider/brandProvider.dart';
import 'package:account/screens/editScreen.dart';
import 'formScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AutoTechProvider()),
        ChangeNotifierProvider(create: (context) => BrandProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Autonomous Technology',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Autonomous Technology'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BrandProvider>(context, listen: false).insertDummyData();
      Provider.of<AutoTechProvider>(context, listen: false).initData();
      Provider.of<BrandProvider>(context, listen: false).initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return FormScreen();
              }));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const Text(
              "รายการเทคโนโลยี",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildAutoTechList(context)),
            Divider(),
            //Expanded(child: _buildBrandList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoTechList(BuildContext context) {
    return Consumer<AutoTechProvider>(
      builder: (context, provider, child) {
        if (provider.techItems.isEmpty) {
          return const Center(
            child: Text(
              'ไม่มีรายการ Auto Tech',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          itemCount: provider.techItems.length,
          itemBuilder: (context, index) {
            AutoTechItem data = provider.techItems[index];
            return _buildListItem(
              title: data.Technology_Name,
              subtitle:
                  '${data.brand.Brand_Name} | ปีที่เปิดตัว: ${data.release_Year}',
              leadingText:
                  data.brand.Brand_Name.substring(0, 1), // ใช้อักษรแรกของแบรนด์
              onDelete: () => provider.deleteAutoTechItem(data.Tech_ID ?? 0),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return EditScreen(item: data);
                }));
              },
            );
          },
        );
      },
    );
  }
/*test Brand
  Widget _buildBrandList(BuildContext context) {
    return Consumer<BrandProvider>(
      builder: (context, provider, child) {
        int itemCount = provider.brandItems.length;
        if (itemCount == 0) {
          return const Center(
              child: Text('ไม่มีรายการ Brand', style: TextStyle(fontSize: 20)));
        }
        return ListView.builder(
          itemCount: itemCount,
          itemBuilder: (context, index) {
            BrandItem data = provider.brandItems[index];
            return _buildListItem(
              title: data.Brand_Name,
              subtitle:
                  '${data.Brand_ID} ก่อตั้งปี: ${data.Founded_Year} | ประเทศ: ${data.Country}',
              onDelete: () => provider.deleteBrandItem(data.Brand_ID ?? 0),
              onTap: () {
                /*
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return EditScreen(item: data);
                }))*/
                ;
              }, leadingText: '',
            );
          },
        );
      },
    );
  }

*/
  Widget _buildListItem({
    required String title,
    required String subtitle,
    required String leadingText,
    required VoidCallback onDelete,
    required VoidCallback onTap,
  }) {
    return Dismissible(
      key: Key(title),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDelete(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          leading: CircleAvatar(
            backgroundColor: Colors.blueGrey,
            child: Text(
              leadingText,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () {
              _showDeleteConfirmation(context, title, onDelete);
            },
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, String title, VoidCallback onDelete) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ยืนยันการลบ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text('คุณต้องการลบ "$title" ใช่หรือไม่?'),
          actions: [
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child:
                  const Text('ลบรายการ', style: TextStyle(color: Colors.red)),
              onPressed: () {
                onDelete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
