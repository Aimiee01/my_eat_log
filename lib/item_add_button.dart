import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_eat_log/review.dart';

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
      if (globalKey.currentState!.validate()) {
        // ファイル名を秒まで入れた文字列にする
        String? imagePath;
        String? imageUrl;
        if (imageFile != null) {
          // timestampは画像がある時にしか使わないのでこの場所に書く
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          imagePath = 'user-id/menu-images/upload-pic-$timestamp.png';
          final imageRef = FirebaseStorage.instance.ref(imagePath);
          // Storageに画像を保存
          await imageRef.putFile(imageFile!);
          // 保存した画像のURLを取得して、あらかじめ用意していた変数に入れる
          imageUrl = await imageRef.getDownloadURL();
        }

        await reviewsRef
            .add(Review(
              shopName: shopNameController.text,
              menuName: menuNameController.text,
              comment: commentController.text,
              imagePath: imagePath,
              imageUrl: imageUrl,
              // imagePathにはファイル名を指定する
            ))
            .then((value) => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('登録されました'))));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('必要な情報を入力してください')));
      }
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
