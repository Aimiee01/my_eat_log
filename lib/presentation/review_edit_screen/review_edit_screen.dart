import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_eat_log/domain/review/entities/review.dart';
import 'package:my_eat_log/domain/review/entities/review_image.dart';
import 'package:my_eat_log/presentation/review_edit_screen/delete_review_button.dart';
import 'package:my_eat_log/presentation/review_edit_screen/edit_images_view.dart';
import 'package:my_eat_log/presentation/review_edit_screen/edit_textfields_view.dart';

import 'edit_rating_view.dart';
import 'review_update_button.dart';

class ReviewEditScreen extends StatefulWidget {
  const ReviewEditScreen({
    Key? key,
    // docとして受け取り
    required this.reviewDoc,
  }) : super(key: key);

  /// 値受け取り用の変数
  /// CollectionReference でgetして得たQuerySnapshotのdocs内にあるもの
  final QueryDocumentSnapshot<Review> reviewDoc;
  // final FirebaseStorage storage;

  @override
  _ReviewEditScreenState createState() => _ReviewEditScreenState();
}

class _ReviewEditScreenState extends State<ReviewEditScreen> {
  // 初期値は空 リストなので各かっこ
  // 一度しか代入しないものは全てfinal
  final List<File> _imageFileList = [];
  // storageに保存されている写真urlリスト
  final List<String> _imageUrlList = [];

  // initState内で代入するのでlateを使う

  late final TextEditingController _shopNameController;
  late final TextEditingController _menuNameController;
  late final TextEditingController _commentController;
  late final Stream<QuerySnapshot<ReviewImage>> reviewImageStream;
  // newRatingは変更される可能性があるのでfinalは付けない
  late double newRating;

  @override
  // fireStoreの文字列を参照する必要があるためinitStateで代入する
  void initState() {
    final review = widget.reviewDoc.data();
    _shopNameController = TextEditingController(text: review.shopName);
    _menuNameController = TextEditingController(text: review.menuName);
    _commentController = TextEditingController(text: review.comment);
    newRating = review.ratingStar;
    // 該当するreviewのreviewImagesを取得
    reviewImageStream = reviewImagesRef(widget.reviewDoc.id)
        .orderBy(ReviewImageField.updatedAt)
        .snapshots();
    // 該当するreviewのimageのURLをリストに追加する
    // .firstを使って一度のみの取得にする
    // thenを使用することで非同期処理になる
    reviewImageStream.first.then((snapshot) {
      // mapでURLを取り出しaddAllでリストに追加
      _imageUrlList.addAll(snapshot.docs.map((e) => e.data().storageUrl));
    });
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
                      imageUrlList: _imageUrlList,
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
                      onRemoveImageUrl: (index) {
                        setState(() {
                          _imageUrlList.removeAt(index);
                        });
                      },
                    ),
                    // ★★★★★表示部分（評価）
                    EditRatingView(
                      // FireStoreに保存されているratingを表示
                      initialRating: newRating,
                      // 新しい評価
                      newRating: (newRatingNum) {
                        setState(() {
                          newRating = newRatingNum;
                        });
                      },
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 削除ボタン
                          Flexible(
                            child: DeleteReviewButton(widget.reviewDoc),
                          ),
                          const SizedBox(width: 16),
                          // 更新ボタン
                          Flexible(
                            child: ItemUpdateButton(
                              snapshot: snapshot,
                              shopNameController: _shopNameController,
                              menuNameController: _menuNameController,
                              commentController: _commentController,
                              ratingStar: newRating,
                              globalKey: _formKey,
                              reviewDoc: widget.reviewDoc,
                              imageFileList: _imageFileList,
                              imageUrlList: _imageUrlList,
                            ),
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
