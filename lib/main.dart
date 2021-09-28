import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:my_eat_log/presentation/rating_order_screen.dart';
import 'presentation/favorite_screen.dart';
import 'presentation/shopname_order_screen.dart';
import 'presentation/setting_screen.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
firebase_storage.FirebaseStorage storage =
    firebase_storage.FirebaseStorage.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class TabInfo {
  TabInfo(this.label, this.widget);
  String label;
  Widget widget;
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final List<TabInfo> _tabs = [
    TabInfo('店名順', const ShopNameOrderScreen()),
    TabInfo('評価順', const RatingOrderScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: _tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('My Eat Log'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: TabBar(
                isScrollable: true,
                tabs: _tabs.map((TabInfo tab) {
                  return Tab(text: tab.label);
                }).toList(),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    // (_)使わないので省略
                    builder: (_) => const FavoriteScreen(),
                  ),
                ),
                icon: const Icon(Icons.favorite),
              )
            ],
            leading: IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  // (_)使わないので省略
                  builder: (_) => const SettingScreen(),
                ),
              ),
              icon: const Icon(Icons.settings),
            ),
          ),
          body: TabBarView(
            children: _tabs.map((e) => e.widget).toList(),
          ),
        )

        // theme: ThemeData.light().copyWith(
        //   elevatedButtonTheme: ElevatedButtonThemeData(
        //     style: ElevatedButton.styleFrom(
        //       minimumSize: const Size.fromHeight(44),
        //     ),
        //   ),
        // ),
        // debugShowCheckedModeBanner: false,
        );
  }
}
