import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_eat_log/domain/review/entities/review.dart';
import 'package:my_eat_log/domain/review/entities/review_image.dart';
import 'package:my_eat_log/domain/review/review_image_repository.dart';
import 'package:my_eat_log/domain/review/review_repository.dart';
import 'package:my_eat_log/presentation/review_edit_screen/edit_images.dart';
import 'package:my_eat_log/presentation/review_edit_screen/edit_textfields.dart';

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
  // 初期値は空 リストなので各かっこ
  final List<File> _imageFileList = [];

  late Stream<QuerySnapshot<ReviewImage>> reviewImageStream;

  // initState内で代入するのでlateを使う
  late TextEditingController _shopNameController;
  late TextEditingController _menuNameController;
  late TextEditingController _commentController;

  @override
  // fireStoreの文字列を参照する必要があるためinitStateで代入する
  void initState() {
    _shopNameController = TextEditingController();
    _menuNameController = TextEditingController();
    _commentController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _menuNameController.dispose();
    _commentController.dispose();
    super.dispose();
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

  // formKeyは共通して使用する
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    // 該当するreviewのreviewImagesを取得
    final reviewImageStream = reviewImagesRef(widget.reviewDoc.id)
        .orderBy(ReviewImageField.updatedAt)
        .snapshots();
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
                    // レビューテキスト入力部分
                    EditTextfieldsView(
                      formKey: _formKey,
                      reviewDoc: widget.reviewDoc,
                      shopNameController: _shopNameController,
                      menuNameController: _menuNameController,
                      commentController: _commentController,
                    ),
                    // 写真表示部分
                    EditImagesView(
                      snapshot: snapshot,
                      reviewDoc: widget.reviewDoc,
                      imageFileList: _imageFileList,
                      addImageFiles: (imageFiles) {
                        setState(() {
                          // Listが更新される
                          _imageFileList.addAll(imageFiles);
                          // imageFileList.removeAtもここで実行する
                        });
                      },
                      removeImageFile: (imageFileindex) {
                        setState(() {
                          _imageFileList.removeAt(imageFileindex);
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ItemDeleteButton(widget.reviewDoc),
                          const SizedBox(width: 50),
                          _ItemUpdateButton(
                            _shopNameController,
                            _menuNameController,
                            _commentController,
                            _formKey,
                            widget.reviewDoc,
                            _imageFileList,
                          ),
                        ],
                      ),
                    ),
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

/// レビュー更新ボタン
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
        //latestImageUrlを最後に追加した写真のURLに更新する
        await ReviewRepository.instance.updateLatestImageUrl(
            reviewImages.last.storageUrl,
            reviewId: reviewDoc.id);
      }
      // reviewの内容を更新する
      await ReviewRepository.instance.update(
        shopNameController.text,
        menuNameController.text,
        commentController.text,
        reviewId: reviewDoc.id,
      );

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

    /// レビュー更新ボタン
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
