import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_eat_log/firebase/review.dart';
import 'package:uuid/uuid.dart';

import 'firebase/review_image.dart';

class ItemAddButton extends StatelessWidget {
  ItemAddButton(
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
    Future<void> addItem() async {
      // validateフォームの入力状態を検証
      if (!globalKey.currentState!.validate()) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('必要な情報を入力してください')));
        return;
      }
      // ファイル名を秒まで入れた文字列にする
      ReviewImage? reviewImage;
      if (imageFile != null) {
        String? storagePath;
        // timestampは画像がある時にしか使わないのでこの場所に書く
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        storagePath = 'user-id/menu-images/upload-pic-$timestamp.png';
        final imageRef = FirebaseStorage.instance.ref(storagePath);
        // Storageに画像を保存
        await imageRef.putFile(imageFile!);
        // 保存した画像のURLを取得して、あらかじめ用意していた変数に入れる
        final storageUrl = await imageRef.getDownloadURL();
        // 新しく追加する画像のクラスを作成
        reviewImage = ReviewImage(
          storagePath: storagePath,
          storageUrl: storageUrl,
          updatedAt: Timestamp.now(),
        );
      }

      // UuidでIDを生成する（packageのimportが必要）バージョンはv4を指定
      final reviewId = const Uuid().v4();
      final storageUrl = reviewImage?.storageUrl;
      await reviewsRef
          .doc(reviewId)
          // IDを指定するとgetは使えないのでsetを使う
          .set(
            Review(
              shopName: shopNameController.text,
              menuName: menuNameController.text,
              comment: commentController.text,
              latestImageUrl: storageUrl,
            ),
          )
          .then(
            (value) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('登録されました'),
              ),
            ),
          );
      if (reviewImage == null) {
        return;
      }
      await reviewImagesRef(reviewId).add(reviewImage);
    }

    return ElevatedButton(
      onPressed: () async {
        await addItem();
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
