import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_eat_log/presentation/review_add_screen/add_images_view.dart';
import 'package:my_eat_log/presentation/review_add_screen/add_rating_view.dart';
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

  /// 評価の初期値として0を代入
  late double rating = 0;
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 文字入力部分
              AddTextfieldsView(
                  formKey: _formKey,
                  shopNameController: _shopNameController,
                  menuNameController: _menuNameController,
                  commentController: _commentController),

              // 写真表示部分
              AddImagesView(imageFileList: _imageFileList),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Text(
                      '評価',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  ),

                  // 評価表示部分
                  AddRatingView(
                    // _ratingで受け取り
                    // ratingにユーザーが入力した値を代入して更新
                    newRatingStarNum: (_rating) {
                      setState(() {
                        rating = _rating;
                      });
                    },
                  )
                ],
              ),
              const SizedBox(height: 24),
              // 新規レビューの「登録」ボタン
              AddReviewButton(_imageFileList,
                  shopNameController: _shopNameController,
                  menuNameController: _menuNameController,
                  commentController: _commentController,
                  ratingStar: rating,
                  globalKey: _formKey),
            ],
          ),
        ),
      ),
    );
  }
}
