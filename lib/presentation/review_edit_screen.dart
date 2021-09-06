import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_eat_log/domain/review/entities/review.dart';
import 'package:my_eat_log/domain/review/entities/review_image.dart';
import 'package:my_eat_log/domain/review/review_image_repository.dart';
import 'package:my_eat_log/domain/review/review_repository.dart';

class ReviewEditScreen extends StatefulWidget {
  const ReviewEditScreen({
    Key? key,
    // docとして受け取り
    required this.reviewDoc,
  }) : super(key: key);

  /// 値受け取り用の変数
  final QueryDocumentSnapshot<Review> reviewDoc;
  // final FirebaseStorage storage;

  @override
  _ReviewEditScreenState createState() => _ReviewEditScreenState();
}

class _ReviewEditScreenState extends State<ReviewEditScreen> {
  final _shopNameController = TextEditingController();
  final _menuNameController = TextEditingController();
  late TextEditingController _commentController;
  // 初期値は空 リストなので各かっこ
  final List<File> _imageFileList = [];

  late Stream<QuerySnapshot<ReviewImage>> reviewImageStream;

  /// ユーザーが写真ギャラリーから写真を選択する
  /// 写真が選ばれたら [_imageFileList] に [File] が入る
  /// キャンセルされた場合は何もしない
  Future<void> onAddImageButtonPressed() async {
    // 修正してもらった部分
    final pickedFiles =
        // await ImagePicker().pickImage(source: ImageSource.gallery);
        await ImagePicker().pickMultiImage();
    if (pickedFiles == null || pickedFiles.isEmpty) {
      return;
    }
    setState(() {
      /// ImagePickerで選択された複数枚の写真
      final files = pickedFiles.map((pickedFile) => File(pickedFile.path));
      _imageFileList.addAll(files);
    });
  }

  Future<void> getImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile == null) {
      return;
    }
    setState(() {
      _imageFileList.add(File(pickedFile.path));
    });
  }

  @override
  void initState() {
    super.initState();
    // ドキュメントのデータを代入
    final review = widget.reviewDoc.data();

    _shopNameController.value =
        _shopNameController.value.copyWith(text: review.shopName);
    _menuNameController.text = review.menuName;
    _commentController = TextEditingController(text: review.comment);
    // 該当するreviewのreviewImagesを取得
    reviewImageStream = reviewImagesRef(widget.reviewDoc.id)
        .orderBy(ReviewImageField.updatedAt)
        .snapshots();
  }

  /// アップロード済みの写真を削除する
  /// 削除された写真より前に登録した写真があれば
  /// latestImageUrlを更新する
  void _onDeleteImageButton({
    // 削除する写真のドキュメント
    required QueryDocumentSnapshot<ReviewImage> doc,
    // 全写真のリスト
    required List<QueryDocumentSnapshot<ReviewImage>> docs,
  }) {
    final data = doc.data();

    setState(() {
      ReviewImageRepository.instance.delete(
        data.storageUrl,
        storagePath: data.storagePath,
        imageDocId: doc.id,
        reviewId: widget.reviewDoc.id,
      );

      debugPrint('docs.last.id == doc.id: ${docs.last.id == doc.id}');

      // 登録済みの最後の写真と削除された写真のIDを比較
      if (docs.last.id != doc.id) {
        // 削除した画像は最後の画像ではなかったので latestImageUrl を書き換える必要はない。早期リターンする
        return;
      }
      // 写真リストから削除された写真を取り除く
      docs.removeLast();

      // 最後の画像を削除していた場合
      if (docs.isEmpty) {
        // latestImageUrl: null にする
        ReviewRepository.instance.updateLatestImageUrl(
          null,
          reviewId: widget.reviewDoc.id,
        );
        return;
      }
      // 最後の画像を削除したが、まだ他に画像が残っている場合
      // 残っている画像のうち、最後の画像を latestImageUrl に設定する
      final lastDoc = docs.last;
      ReviewRepository.instance.updateLatestImageUrl(
        lastDoc.data().storageUrl,
        reviewId: widget.reviewDoc.id,
      );
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('編集画面'),
      ),
      body: SafeArea(
        // FutureBuilderを使ってreviewのサブコレクションimagesのdocumentを入れる
        child: StreamBuilder<QuerySnapshot<ReviewImage>>(
          stream: reviewImageStream,
          builder: (context, asyncValue) {
            // 写真がなければ空白を表示
            if (!asyncValue.hasData || asyncValue.hasError) {
              return const SizedBox();
            }
            final snapshot = asyncValue.data!;
            return Padding(
              padding: const EdgeInsets.all(15),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 4),
                          TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'お店の名前を入力してください';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              icon: Icon(Icons.food_bank_outlined),
                              border: OutlineInputBorder(),
                              labelText: 'お店の名前 *',
                            ),
                            controller: _shopNameController,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '品名を入力してください';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                icon: Icon(Icons.fastfood),
                                border: OutlineInputBorder(),
                                labelText: '商品名 *',
                              ),
                              controller: _menuNameController,
                            ),
                          ),
                          TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '感想を入力してください';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                              icon: Icon(Icons.comment),
                              border: OutlineInputBorder(),
                              labelText: '感想 *',
                            ),
                            controller: _commentController,
                            minLines: 4,
                            maxLines: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    // アップロード済みの写真があったら表示する
                    if (snapshot.docs.isNotEmpty)
                      SizedBox(
                        height: 160,
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 6,
                            crossAxisSpacing: 6,
                          ),
                          itemCount: snapshot.docs.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                showDialog<void>(
                                  context: context,
                                  builder: (_) {
                                    return AlertDialog(
                                      title: const Text('削除してもいいですか？'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('キャンセル'),
                                        ),
                                        // FirebaseStorageに保存済みの写真を削除する
                                        TextButton(
                                          onPressed: () => _onDeleteImageButton(
                                            doc: snapshot.docs[index],
                                            docs: snapshot.docs,
                                          ),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              // タッチ検出対象のWidget
                              // [CachedNetworkImage]にstorageUrlを指定して保存済みの写真を表示
                              child: CachedNetworkImage(
                                  imageUrl:
                                      snapshot.docs[index].data().storageUrl),
                            );
                          },
                        ),
                      ),

                    /// ifで写真が選ばれていたら表示する処理
                    /// ...スプレッド演算子を使ってtrueのとき表示したいWidgetを囲む
                    if (_imageFileList.isNotEmpty) ...[
                      const Text(
                        '新しく追加する写真',
                        style: TextStyle(
                            color: Colors.lightBlue,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 160,
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 6,
                            crossAxisSpacing: 6,
                          ),
                          itemCount: _imageFileList.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                showDialog<void>(
                                    context: context,
                                    builder: (_) {
                                      return AlertDialog(
                                        title: const Text('削除してもいいですか？'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('キャンセル')),
                                          TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _imageFileList
                                                      .removeAt(index);
                                                });
                                                Navigator.pop(context);
                                              },
                                              child: const Text('OK')),
                                        ],
                                      );
                                    });
                              },
                              // タッチ検出対象のWidget
                              child: Image.file(_imageFileList[index]),
                            );
                          },
                        ),
                      ),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Colors.blue[600]),
                          onPressed: onAddImageButtonPressed,
                          // カメラロールを開く
                          child: const Text('写真を選択'),
                        ),
                        const SizedBox(width: 50),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            onPrimary: Colors.blue[600],
                            primary: Colors.blue[100],
                          ),
                          onPressed: getImageFromCamera,
                          // カメラを起動
                          child: const Text('写真を撮影'),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: _ItemUpdateButton(
                        _shopNameController,
                        _menuNameController,
                        _commentController,
                        _formKey,
                        widget.reviewDoc,
                        _imageFileList,
                      ),
                    ),
                    _ItemDeleteButton(widget.reviewDoc),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ItemUpdateButton extends StatelessWidget {
  _ItemUpdateButton(
    this.shopNameController,
    this.menuNameController,
    this.commentController,
    this.globalKey,
    this.reviewDoc,
    this.imageFileList, {
    Key? key,
  }) : super(key: key);

  final TextEditingController shopNameController;
  final TextEditingController menuNameController;
  final TextEditingController commentController;
  // <FormState>を必ず入れる(ジェネリクス)
  final GlobalKey<FormState> globalKey;
  final QueryDocumentSnapshot<Review> reviewDoc;

  List<File> imageFileList = [];

  @override
  Widget build(BuildContext context) {
    Future<void> updateItem() async {
      // validateフォームの入力状態を検証
      if (!globalKey.currentState!.validate()) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('必要な情報を入力してください')));
        return;
      }

      /// レビューを更新する
      final reviewImages = <ReviewImage>[];
      // 写真が選択されていればfirebase Storageに保存する
      if (imageFileList.isNotEmpty) {
        String? storagePath;
        // timestampは写真がある時にしか使わないのでこの場所に書く
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        // 写真の枚数だけ写真をupload→Urlを取得
        for (var i = 0; i < imageFileList.length; i++) {
          // 秒まで入れたfile名を生成
          storagePath = 'user-id/menu-images/upload-pic-$timestamp-$i.png';
          final storageUrl = await ReviewImageRepository.instance.putImage(
            imageFileList[i],
            path: storagePath,
          );

          reviewImages.add(
            ReviewImage(
              storagePath: storagePath,
              storageUrl: storageUrl,
              updatedAt: Timestamp.now(),
            ),
          );
        }
      }
      // 新しく追加する写真があればlatestStorageUrlを更新する
      if (imageFileList.isNotEmpty) {
        final latestStorageUrl = reviewImages.last.storageUrl;
        await ReviewRepository.instance.update(
          shopNameController.text,
          menuNameController.text,
          commentController.text,
          latestStorageUrl,
          reviewId: reviewDoc.id,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('登録されました'),
        ),
      );
      // imagePathにはファイル名を指定する
      if (reviewImages.isNotEmpty) {
        for (final reviewImage in reviewImages) {
          await ReviewImageRepository.instance.add(
            reviewImage,
            reviewId: reviewDoc.id,
          );
        }
      }
    }

    return ElevatedButton(
      onPressed: () async {
        await updateItem();
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
          primary: Colors.blue, onPrimary: Colors.white),
      child: const Text(
        '更新',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}

class _ItemDeleteButton extends StatelessWidget {
  const _ItemDeleteButton(this.reviewDoc, {Key? key}) : super(key: key);
  final QueryDocumentSnapshot<Review> reviewDoc;

  @override
  Widget build(BuildContext context) {
    Future<void> deleteReview(BuildContext context) async {
      await reviewsRef.doc(reviewDoc.id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('削除されました'),
        ),
      );
    }

    return ElevatedButton(
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('削除してもいいですか？'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, 'キャンセル'),
                child: const Text('キャンセル')),
            TextButton(
                onPressed: () async {
                  await deleteReview(context);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('OK')),
          ],
        ),
      ),
      style: ElevatedButton.styleFrom(
          primary: Colors.redAccent, onPrimary: Colors.white),
      child: const Text(
        '削除',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}
