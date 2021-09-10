import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_eat_log/presentation/review_add_screen/add_images_view.dart';
import 'package:my_eat_log/presentation/review_add_screen/add_textfields_view.dart';
import 'add_review_button.dart';

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
                AddTextfieldsView(
                    formKey: _formKey,
                    shopNameController: _shopNameController,
                    menuNameController: _menuNameController,
                    commentController: _commentController),
                AddImagesView(imageFileList: _imageFileList),
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
                // 登録ボタン
                AddReviewButton(_imageFileList,
                    shopNameController: _shopNameController,
                    menuNameController: _menuNameController,
                    commentController: _commentController,
                    globalKey: _formKey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
