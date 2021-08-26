import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_eat_log/domain/review/entities/review.dart';
import 'package:my_eat_log/domain/review/entities/review_image.dart';

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
  // 初期値は空なので？（lateは使えない）
  File? _imageFile;

  late Future<QuerySnapshot<ReviewImage>> reviewImageFuture;

  // Future<void> downloadFile(String imagePath) async {
  //   final imageurl = widget.storage.ref().child('images/$imagePath');
  //   final String url = await ref.getDownloadURL();
  //   final img = Image(image: CacheNetworkImageProvider(url));
  // }

  /// ユーザーが写真ギャラリーから写真を選択する
  /// 写真が選ばれたら [_imageFile] に [File] が入る
  /// キャンセルされた場合は何もしない
  Future<void> getImage() async {
    // 修正してもらった部分
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return;
    }
    setState(() {
      /// ImagePickerで選択された画像
      _imageFile = File(pickedFile.path);
    });
  }

  @override
  void initState() {
    super.initState();
    final review = widget.reviewDoc.data();

    _shopNameController.value =
        _shopNameController.value.copyWith(text: review.shopName);
    _menuNameController.text = review.menuName;
    _commentController = TextEditingController(text: review.comment);
    // 該当するreviewのreviewImagesを取得
    reviewImageFuture = reviewImagesRef(widget.reviewDoc.id)
        .orderBy(ReviewImageField.updatedAt)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    // コメントを更新したいとき（reference は参照）
    // widget.reviewDoc.reference.update({'comment': ''});
    return Scaffold(
      appBar: AppBar(
        title: const Text('編集画面'),
      ),
      body: SafeArea(
        // FutureBuilderを使ってreviewImageのdocumentを入れる
        child: FutureBuilder<QuerySnapshot<ReviewImage>>(
            future: reviewImageFuture,
            builder: (context, asyncValue) {
              // 写真がなければ空白を表示
              if (!asyncValue.hasData || asyncValue.hasError) {
                return const SizedBox();
              }
              final snapshot = asyncValue.data!;
              // 以下を使って写真を表示
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
                              padding: const EdgeInsets.symmetric(vertical: 30),
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
                      // カメラロールで選択された写真を優先する
                      if (_imageFile != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: SizedBox(
                              width: 200, child: Image.file(_imageFile!)),
                        )

                      /// isNotEmptyを使って画像がある時はそれを表示する処理
                      else if (snapshot.docs.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: SizedBox(
                              width: 200,
                              child: Image.network(
                                  snapshot.docs.last.data().storageUrl)),
                        )
                      else
                        // 何も選ばれなければIconを表示
                        const Icon(Icons.image_outlined),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              onPrimary: Colors.blue[600],
                              primary: Colors.blue[100]),
                          onPressed: getImage,
                          // 画像をカメラロールを開く
                          child: const Text('写真を選択'),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: _ItemUpdateButton(
                          _shopNameController,
                          _menuNameController,
                          _commentController,
                          _formKey,
                          widget.reviewDoc,
                          _imageFile,
                        ),
                      ),
                      _ItemDeleteButton(widget.reviewDoc),
                    ],
                  ),
                ),
              );
            }),
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
    this.imageFile, {
    Key? key,
  }) : super(key: key);

  final TextEditingController shopNameController;
  final TextEditingController menuNameController;
  final TextEditingController commentController;
  // <FormState>を必ず入れる(ジェネリクス)
  final GlobalKey<FormState> globalKey;
  final QueryDocumentSnapshot<Review> reviewDoc;

  File? imageFile;

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
      ReviewImage? reviewImage;
      String? storageUrl;
      String? storagePath;
      // 画像が選択されていればfirebase Storageに保存する
      if (imageFile != null) {
        // timestampは画像がある時にしか使わないのでこの場所に書く
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        storagePath = 'user-id/menu-images/upload-pic-$timestamp.png';
        final imageRef = FirebaseStorage.instance.ref(storagePath);
        // Storageに画像を保存
        await imageRef.putFile(imageFile!);
        // 保存した画像のURLを取得して、あらかじめ用意していた変数に入れる
        storageUrl = await imageRef.getDownloadURL();
        // 追加する画像のクラスを作成
        reviewImage = ReviewImage(
          storagePath: storagePath,
          storageUrl: storageUrl,
          updatedAt: Timestamp.now(),
        );
      }
      await reviewsRef.doc(reviewDoc.id).update({
        ReviewField.shopName: shopNameController.text,
        ReviewField.menuName: menuNameController.text,
        ReviewField.comment: commentController.text,
        if (storageUrl != null) ReviewField.latestImageUrl: storageUrl,
        // todo サーバーの時刻を保存
        // 'updatedAt': FieldValue.serverTimestamp(),
      }
          // imagePathにはファイル名を指定する
          ).then((value) => ScaffoldMessenger.of(
              context)
          .showSnackBar(const SnackBar(content: Text('更新されました'))));
      if (reviewImage == null) {
        return;
      }
      await reviewImagesRef(reviewDoc.id).add(reviewImage);
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