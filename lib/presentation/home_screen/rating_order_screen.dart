import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_eat_log/domain/review/entities/review.dart';
import 'package:my_eat_log/domain/review/review_repository.dart';
import 'package:my_eat_log/presentation/review_edit_screen/review_edit_screen.dart';

import '../review_add_screen/review_add_screen.dart';

class RatingOrderScreen extends StatefulWidget {
  const RatingOrderScreen({Key? key}) : super(key: key);

  @override
  _RatingOrderScreenState createState() => _RatingOrderScreenState();
}

class _RatingOrderScreenState extends State<RatingOrderScreen> {
  /// すべてのレビューコレクション
  late Stream<QuerySnapshot<Review>> _reviewCollectionStream;

  @override
  void initState() {
    super.initState();

    _reviewCollectionStream = ReviewRepository.instance.fetchAllRating();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            const cardHeight = 300;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: cardWidth / cardHeight,
              ),
              padding: const EdgeInsets.all(8),
              itemCount: snapshotData.docs.length,
              itemBuilder: (context, index) {
                // ↓どのデータか(docsはクエリの結果として得られた配列)
                final doc = snapshotData.docs[index];
                // mapとして取り出しreviewに代入
                final review = doc.data();
                // 1枚目の写真があれば使い、なければstorageUrlを利用する
                final latestImageUrl = review.latestImageUrl;
                return InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          // 該当するdocを渡す
                          ReviewEditScreen(
                        reviewDoc: doc,
                      ),
                    ),
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: cardWidth - 5,
                          height: (cardHeight / 2) + 20,
                          child: latestImageUrl == null
                              ? Image.asset('assets/images/no_image.png')
                              : CachedNetworkImage(
                                  imageUrl: latestImageUrl,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            review.shopName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            review.menuName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black38,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          // 評価を取得して表示する
                          child: RatingBarIndicator(
                            rating:
                                // ここに該当する評価の数値を入れる
                                review.ratingStar,
                            itemBuilder: (context, index) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 20,
                            direction: Axis.horizontal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Text('読み込み中');
        },
      ),
    );
  }
}
