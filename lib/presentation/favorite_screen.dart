import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_eat_log/domain/review/entities/review.dart';
import 'package:my_eat_log/domain/review/review_repository.dart';

import 'review_edit_screen/review_edit_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late Stream<QuerySnapshot<Review>> _reviewCollectionStream;

  @override
  void initState() {
    super.initState();
    _reviewCollectionStream = ReviewRepository.instance.fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('お気に入り'),
      ),
      body: StreamBuilder<QuerySnapshot<Review>>(
        stream: _reviewCollectionStream,
        // snapshotでデータを取得
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // snapshotにdataがあれば取得して表示
            final snapshotData = snapshot.data!;

            // 画面の横幅
            final displayWidth = MediaQuery.of(context).size.width;
            // カードの横幅を算出
            final cardWidth = (displayWidth - ((5 * 2) + 10)) / 2;
            // カードの高さを指定
            const cardHeight = 100;

            return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: snapshotData.docs.length,
                itemBuilder: (context, index) {
                  // ↓どのデータか(docsはクエリの結果として得られた配列)
                  final doc = snapshotData.docs[index];
                  // mapとして取り出しreviewに代入
                  final review = doc.data();
                  // 1枚目の写真があれば使い、なければstorageUrlを利用する
                  final latestImageUrl = review.latestImageUrl;

                  if (review.favoriteEnable == true) {
                    return ListTile(
                      title: Text(review.shopName),
                      subtitle: Text(review.menuName),
                      leading: SizedBox(
                        width: cardWidth / 3,
                        height: cardHeight / 2,
                        child: latestImageUrl == null
                            ? Image.asset('assets/images/no_image.png')
                            : Image.network(
                                latestImageUrl,
                                fit: BoxFit.cover,
                              ),
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              // 該当するdocを渡す
                              ReviewEditScreen(
                            reviewDoc: doc,
                          ),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    );
                  }
                  return Container();
                });
          }
          return const Text('読み込み中');
        },
      ),
    );
  }
}
