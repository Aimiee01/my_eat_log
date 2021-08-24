import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_eat_log/firebase/review.dart';
import 'package:my_eat_log/screens/favorite_screen.dart';
import 'package:my_eat_log/screens/review_edit_screen.dart';
import 'package:my_eat_log/setting_screen.dart';
import 'review_add_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // コレクションを取得する場合の書き方
    final snapshots = reviewsRef.snapshots();
    // ryunosuke add
    // snapshots.map((snapshot) => snapshot.docs.map((e) {
    //       final review = e.data();
    //       final image = reviewImagesRef(e.id).snapshots().first;
    //     }));

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyLog'),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      // (_)使わないので省略
                      builder: (_) => const FavoriteScreen(),
                    ),
                  ),
              icon: const Icon(Icons.favorite))
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const ReviewAddScreen(),
          ),
        ),
        child: const Icon(Icons.restaurant),
      ),
      // ↓取得したコレクションをリスト化
      body: StreamBuilder<QuerySnapshot<Review>>(
          stream: snapshots,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // snapshotにdataがあれば取得して表示
              final snapshotData = snapshot.data!;
              return ListView.separated(
                itemBuilder: (context, index) {
                  // ↓どのデータか(docsはクエリの結果として得られた配列)
                  final doc = snapshotData.docs[index];
                  // mapとして取り出しreviewに代入
                  final review = doc.data();
                  // 1枚目の写真があれば使い、なければstorageUrlを利用する
                  final latestImageUrl = review.latestImageUrl;
                  return ListTile(
                    // imageUrlがあれば表示
                    leading: latestImageUrl == null
                        ? const Icon(Icons.image_outlined)
                        : Image.network(latestImageUrl),
                    title: Text(review.shopName),
                    subtitle: Text(review.menuName),

                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            // 該当するdocを渡す
                            ReviewEditScreen(
                          reviewDoc: doc,
                        ),
                      ),
                    ),
                  );
                },
                // ↓ListTileの間隔をあける
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemCount: snapshotData.docs.length,
              );
            }
            return const Text('読み込み中');
          }),
    );
  }
}
