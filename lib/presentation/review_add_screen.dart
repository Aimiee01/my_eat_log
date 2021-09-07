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
  final List<File> _imageFileList = [];

  /// ユーザーが選択したデバイスの写真ファイル
  File? imageFile;

  /// ユーザーが写真を選択する
  Future<void> onAddImageButtonPressed() async {
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
                      if (_imageFileList.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: SizedBox(
                            width: 350,
                            height: 70,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _imageFileList.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return const SizedBox(
                                    width: 115,
                                    child: TextButton(
                                      onPressed: null,
                                      child: Text('+'),
                                    ),
                                  );
                                }

                                final imageFileIndex = index - 1;
                                final imageFile =
                                    _imageFileList[imageFileIndex];
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
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: Image.file(imageFile),
                                  ),
                                );
                              },
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
                  _imageFileList,
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
  const _ItemAddButton(
    this.shopNameController,
    this.menuNameController,
    this.commentController,
    this.globalKey,
    this._imageFileList,
    // ボタンを用意してからimagePickerを使う
    {
    Key? key,
  }) : super(key: key);
  final TextEditingController shopNameController;
  final TextEditingController menuNameController;
  final TextEditingController commentController;

  /// カメラロールで選択された写真のリスト
  final List<File> _imageFileList;

  // <FormState>を必ず入れる
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

      /// reviewImagesクラスのリストを作成・型はReviewImageを指定
      /// reviewのサブコレクションimages
      final reviewImages = <ReviewImage>[];
      if (_imageFileList.isNotEmpty) {
        String? storagePath;
        // timestampは写真がある時にしか使わないのでこの場所に書く
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        // 写真の枚数だけ写真をupload→Urlを取得
        for (var i = 0; i < _imageFileList.length; i++) {
          // 秒まで入れたfile名を生成
          storagePath = 'user-id/menu-images/upload-pic-$timestamp-$i.png';
          final storageUrl = await ReviewImageRepository.instance.putImage(
            _imageFileList[i],
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

      // UuidでReviewID(DocumentIDとしても使う)を生成する（packageのimportが必要）バージョンはv4を指定
      final reviewId = const Uuid().v4();
      final newReview = Review(
        shopName: shopNameController.text,
        menuName: menuNameController.text,
        comment: commentController.text,
        latestImageUrl:
            reviewImages.isEmpty ? null : reviewImages.last.storageUrl,
      );
      await ReviewRepository.instance.add(
        newReview,
        reviewId: reviewId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('登録されました'),
        ),
      );

      // 画像を reviews/:id/images コレクションに追加する
      if (reviewImages.isNotEmpty) {
        for (final reviewImage in reviewImages) {
          await ReviewImageRepository.instance.add(
            reviewImage,
            reviewId: reviewId,
          );
        }
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
