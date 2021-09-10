import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_eat_log/domain/review/entities/review.dart';
import 'package:my_eat_log/domain/review/entities/review_image.dart';
import 'package:my_eat_log/presentation/review_edit_screen/edit_images_view.dart';
import 'package:my_eat_log/presentation/review_edit_screen/edit_textfields_view.dart';
import 'package:my_eat_log/presentation/review_edit_screen/delete_review_button.dart';

import 'review_update_button.dart';

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
                        });
                      },
                      removeImageFile: (imageFileindex) {
                        setState(() {
                          _imageFileList.removeAt(imageFileindex);
                        });
                      },
                    ),
                    // 更新・削除ボタン部分
                    Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DeleteReviewButton(widget.reviewDoc),
                          const SizedBox(width: 50),
                          ItemUpdateButton(
                            shopNameController: _shopNameController,
                            menuNameController: _menuNameController,
                            commentController: _commentController,
                            globalKey: _formKey,
                            reviewDoc: widget.reviewDoc,
                            imageFileList: _imageFileList,
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
