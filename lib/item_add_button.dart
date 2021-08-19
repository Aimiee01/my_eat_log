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
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final imagePath = 'user-id/menu-images/upload-pic-$timestamp.png';
        // if文で囲む

        await FirebaseStorage.instance
            // ファイル名を秒まで入れた文字列にする
            .ref(imagePath)
            .putFile(imageFile!);

        await reviewsRef
            .add(Review(
              shopName: shopNameController.text,
              menuName: menuNameController.text,
              comment: commentController.text,
              imageUrl: imagePath,
              // imageUrlにはファイル名を指定する
            ))
            .then((value) => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('登録されました'))));

        return;
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
