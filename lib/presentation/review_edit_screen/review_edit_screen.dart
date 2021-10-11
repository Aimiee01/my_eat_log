import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_eat_log/domain/review/entities/review.dart';
import 'package:my_eat_log/domain/review/entities/review_image.dart';
import 'package:my_eat_log/domain/review/review_image_repository.dart';
import 'package:my_eat_log/presentation/review_add_screen/add_date_view.dart';
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
  late bool favoriteEnable;
  late String latestVisitedDate;

  void favoritedCallback() {}

  @override
  // fireStoreの文字列を参照する必要があるためinitStateで代入する
  void initState() {
    final review = widget.reviewDoc.data();
    _shopNameController = TextEditingController(text: review.shopName);
    _menuNameController = TextEditingController(text: review.menuName);
    _commentController = TextEditingController(text: review.comment);
    newRating = review.ratingStar;

    // Firestoreのお気に入り情報を代入
    favoriteEnable = review.favoriteEnable;
    latestVisitedDate = widget.reviewDoc.data().visitedDate;

    // 該当するreviewのreviewImagesを取得
    reviewImageStream = reviewImagesRef(widget.reviewDoc.id)
        .orderBy(ReviewImageField.updatedAt)
        .snapshots();
    // .firstを使って一度のみの取得にする
    // Futureクラスのthenを使用して非同期処理
    reviewImageStream.first.then((snapshot) {
      // mapでURLを取り出しaddAllでリストに追加
      // 該当するreviewのimageのURLをリストに追加する
      _imageUrlList.addAll(snapshot.docs.map((e) => e.data().storageUrl));
    });

    super.initState();
  }

  final _deleteImageList = <DeleteImageParameter>[];

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
        // reviewのサブコレクションimagesのdocumentを入れる
        child: FutureBuilder<QuerySnapshot<ReviewImage>>(
          // FutureBuilderなのでstreamの部分はfutureになる
          // そこで.firstを使い一度だけ取得する
          future: reviewImageStream.first,
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
                    // 来店日
                    AddDateView(
                        visitedDate: widget.reviewDoc.data().visitedDate,
                        visitedDateChanged: (_visitedDateChanged) {
                          setState(() {
                            latestVisitedDate = _visitedDateChanged;
                          });
                        }),
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
                      removeImageUrls: (imageUrlIndex) {
                        setState(() {
                          _imageUrlList.removeAt(imageUrlIndex);
                        });
                      },
                      onDeleteImageParameter: (deleteImageParameter) {
                        setState(() {
                          // 削除予定の写真をリストに追加
                          _deleteImageList.add(deleteImageParameter);
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
                    if (favoriteEnable)
                      TextButton(
                        // TODO タップした時にお気に入りを反転させる処理
                        onPressed: favoritedCallback,
                        child: const Text('お気に入りに追加済み'),
                      ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 削除ボタン
                        Flexible(
                          child: DeleteReviewButton(widget.reviewDoc),
                        ),
                        const SizedBox(width: 16),
                        // 更新ボタン
                        Flexible(
                          child: ReviewUpdateButton(
                            snapshot: snapshot,
                            shopNameController: _shopNameController,
                            menuNameController: _menuNameController,
                            commentController: _commentController,
                            ratingStar: newRating,
                            globalKey: _formKey,
                            reviewDoc: widget.reviewDoc,
                            imageFileList: _imageFileList,
                            imageUrlList: _imageUrlList,
                            deleteImageList: _deleteImageList,
                            latestVisitedDate: latestVisitedDate,
                          ),
                        ),
                      ],
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
