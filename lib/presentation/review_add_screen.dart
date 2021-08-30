import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_eat_log/domain/review/entities/review.dart';
import 'package:my_eat_log/domain/review/entities/review_image.dart';
import 'package:my_eat_log/domain/review/review_image_repository.dart';
import 'package:my_eat_log/domain/review/review_repository.dart';
import 'package:uuid/uuid.dart';

class ReviewAddScreen extends StatefulWidget {
  const ReviewAddScreen({Key? key}) : super(key: key);

  @override
  _ReviewAddScreenState createState() => _ReviewAddScreenState();
}

class _ReviewAddScreenState extends State<ReviewAddScreen> {
  /// Formで指定するキー
  final _formKey = GlobalKey<FormState>();
  // 入力フォームのコントローラー
  final _shopNameController = TextEditingController();
  final _menuNameController = TextEditingController();
  final _commentController = TextEditingController();

  /// ユーザーが選択したデバイスの写真ファイル
  File? imageFile;

  /// ユーザーが写真を選択する
  Future<void> onAddImageButtonPressed() async {
    // 修正してもらった部分
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return;
    }
    setState(() {
      imageFile = File(pickedFile.path);
    });
  }

  Future<void> getImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile == null) {
      return;
    }
    setState(() {
      imageFile = File(pickedFile.path);
    });
  }

  @override
  void dispose() {
    // 画面遷移したらコントローラーを破棄する必要があるので破棄
    _shopNameController.dispose();
    _menuNameController.dispose();
    _commentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新規登録')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '店舗名を入力してください';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          icon: Icon(Icons.food_bank_outlined),
                          border: OutlineInputBorder(),
                          labelText: '店舗名 *',
                        ),
                        controller: _shopNameController,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '品名を入力してください';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            icon: Icon(Icons.fastfood),
                            border: OutlineInputBorder(),
                            hintText: '品名を入力してください',
                            labelText: '品名 *',
                          ),
                          controller: _menuNameController,
                        ),
                      ),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '感想を入力してください';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          icon: Icon(Icons.comment),
                          border: OutlineInputBorder(),
                          hintText: '感想を入力してください',
                          labelText: '感想 *',
                        ),
                        controller: _commentController,
                        minLines: 6,
                        maxLines: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: SizedBox(
                          width: 200,
                          child: Container(
                            child: imageFile == null
                                ? const Center(child: Text('写真を選択してください'))
                                : Image.file(imageFile!),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.blue[600]),
                            onPressed: onAddImageButtonPressed,
                            // 画像をカメラロールを開く
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
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('評価'),
                    Text(
                      '★★★★☆',
                      style: TextStyle(fontSize: 20, color: Colors.yellow[800]),
                    ),
                  ],
                ),
                _ItemAddButton(
                  _shopNameController,
                  _menuNameController,
                  _commentController,
                  _formKey,
                  imageFile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemAddButton extends StatelessWidget {
  _ItemAddButton(
    this.shopNameController,
    this.menuNameController,
    this.commentController,
    this.globalKey,
    this.imageFile,
    // ボタンを用意してからimagePickerを使う
    {
    Key? key,
  }) : super(key: key);
  final TextEditingController shopNameController;
  final TextEditingController menuNameController;
  final TextEditingController commentController;
  File? imageFile;

  // <FormState>を必ず入れる(ジェネリクス)
  final GlobalKey<FormState> globalKey;
  @override
  Widget build(BuildContext context) {
    /// レビュー登録するボタンが押された時の処理
    Future<void> _onSaveButtonPressed() async {
      // validateフォームの入力状態を検証
      if (!globalKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('必要な情報を入力してください')),
        );
        return;
      }
      // ファイル名を秒まで入れた文字列にする
      ReviewImage? reviewImage;
      if (imageFile != null) {
        final imageFile = this.imageFile!;

        String? storagePath;
        // timestampは画像がある時にしか使わないのでこの場所に書く
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        storagePath = 'user-id/menu-images/upload-pic-$timestamp.png';

        final storageUrl = await ReviewImageRepository.instance.putImage(
          imageFile,
          path: storagePath,
        );

        // 新しく追加する画像のクラスを作成
        reviewImage = ReviewImage(
          storagePath: storagePath,
          storageUrl: storageUrl,
          updatedAt: Timestamp.now(),
        );
      }

      // UuidでReviewID(DocumentIDとしても使う)を生成する（packageのimportが必要）バージョンはv4を指定
      final reviewId = const Uuid().v4();
      final storageUrl = reviewImage?.storageUrl;
      final newReview = Review(
        shopName: shopNameController.text,
        menuName: menuNameController.text,
        comment: commentController.text,
        latestImageUrl: storageUrl,
      );
      await ReviewRepository.instance.add(newReview, reviewId: reviewId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('登録されました'),
        ),
      );

      if (reviewImage != null) {
        await ReviewImageRepository.instance.add(
          reviewImage,
          reviewId: reviewId,
        );
      }
    }

    return ElevatedButton(
      onPressed: () async {
        await _onSaveButtonPressed();
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
          primary: Colors.blue, onPrimary: Colors.white),
      child: const Text(
        '登録',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}
