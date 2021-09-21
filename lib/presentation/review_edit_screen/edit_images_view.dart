import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_eat_log/domain/review/entities/review.dart';
import 'package:my_eat_log/domain/review/entities/review_image.dart';
import 'package:my_eat_log/domain/review/review_image_repository.dart';

class EditImagesView extends StatefulWidget {
  const EditImagesView({
    Key? key,

    /// 該当するreviewの全写真
    required this.snapshot,
    required this.imageUrlList,
    required this.reviewDoc,
    required this.imageFileList,
    // 新しく選択された写真たち
    required this.addImageFiles,
    // 新しく選択された写真の中で、削除する写真たち
    required this.removeImageFile,
    required this.removeImageUrls,
    required this.onDeleteImageParameter,
  }) : super(key: key);

  final QuerySnapshot<ReviewImage> snapshot;
  final QueryDocumentSnapshot<Review> reviewDoc;

  /// ユーザーが選択した写真のリスト
  final List<File> imageFileList;
  final ValueChanged<List<File>> addImageFiles;

  /// アップロード済み写真のURLリスト
  final List<String> imageUrlList;

  /// 追加予定の画像ファイルを削除した時のコールバック
  final ValueChanged<int> removeImageFile;

  /// アップロード済み写真のURLを削除した時のコールバック
  final ValueChanged<int> removeImageUrls;

  /// アップロード済み写真を削除予約するためのコールバック
  final ValueChanged<DeleteImageParameter> onDeleteImageParameter;

  @override
  _EditImagesViewState createState() => _EditImagesViewState();
}

class _EditImagesViewState extends State<EditImagesView> {
  /// ユーザーが写真ギャラリーから写真を選択する
  /// 写真が選ばれたら `widget.imageFileList` に [File] が入る
  /// キャンセルされた場合は何もしない
  ///   /// ユーザーが選択したデバイスの写真ファイル
  File? imageFile;
  // 削除予定の写真リスト
  final List<DeleteImageParameter> deleteImageList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final imageFileList = widget.imageFileList;
    final imageUrlList = widget.imageUrlList;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        width: 350,
        height: 70,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          // プラスボタンを表示するので2つのlengthの合計に+1する
          itemCount: imageUrlList.length + imageFileList.length + 1,

          itemBuilder: (context, index) {
            // 写真がどこにも存在しない場合+ボタンを表示
            if (index == 0) {
              return SizedBox(
                width: 80,
                child: TextButton(
                  // 選択肢のダイアログを開く
                  onPressed: onAddImageButtonPressed,
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 40),
                    backgroundColor: Colors.grey,
                    primary: Colors.white,
                  ),
                  child: const Text('+'),
                ),
              );
            }
            // 新しく追加する写真がある場合
            // 追加する写真の枚数とindex
            if (index <= imageFileList.length) {
              // + の分、1を引く
              final imageFileIndex = index - 1;
              final imageFile = imageFileList[imageFileIndex];
              return GestureDetector(
                onTap: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: const Text('削除してもいいですか？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('キャンセル'),
                          ),
                          TextButton(
                            onPressed: () {
                              widget.removeImageFile(imageFileIndex);
                              Navigator.pop(context);
                            },
                            child: const Text('削除'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Container(
                      width: 70,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black38,
                          width: 4,
                        ),
                      ),
                      child: Image.file(imageFile)),
                ),
              );
            }
            // 残りはアップロード済みの写真
            final docsIndex = index - (imageFileList.length + 1);
            final imageUrl = imageUrlList[docsIndex];
            final doc = widget.snapshot.docs[docsIndex];

            // reviewのimagesサブコレクションを削除する

            return GestureDetector(
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: const Text('写真を削除'),
                      content: const Text('更新ボタンを押すと削除が実行されます'),
                      contentTextStyle: const TextStyle(color: Colors.black),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('キャンセル'),
                        ),
                        // FirebaseStorageに保存済みの写真を削除する
                        TextButton(
                          style: TextButton.styleFrom(
                            primary: Colors.redAccent,
                          ),
                          onPressed: () {
                            // DeleteImageParameterを渡す
                            widget.onDeleteImageParameter(
                              DeleteImageParameter(
                                documentId: doc.id,
                                storagePath: doc.data().storagePath,
                              ),
                            ); // 削除予定の写真を非表示にする
                            widget.removeImageUrls(docsIndex);
                            Navigator.pop(context);
                          },
                          child: const Text('削除'),
                        ),
                      ],
                    );
                  },
                );
              },
              // [CachedNetworkImage]にstorageUrlを指定して
              // 保存済みの写真を表示
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Image.network(imageUrl),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> onAddImageButtonPressed() async {
    // final pickedFiles = await ImagePicker().pickMultiImage();
    // if (pickedFiles == null || pickedFiles.isEmpty) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            children: [
              SimpleDialogOption(
                onPressed: selectImagesButton,
                padding: const EdgeInsets.all(20),
                child: const Text('カメラロールを開く'),
              ),
              SimpleDialogOption(
                onPressed: getImageFromCamera,
                padding: const EdgeInsets.all(20),
                child: const Text('カメラを起動する'),
              ),
            ],
          );
        });
  }

  Future<void> selectImagesButton() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    // ↑写真を選択するときのawaitを入れ忘れていた
    setState(() {
      if (pickedFiles != null) {
        /// ImagePickerで選択された複数枚の写真
        final files = pickedFiles.map((pickedFile) => File(pickedFile.path));
        widget.addImageFiles(files.toList());
      }
    });
    Navigator.pop(context);
  }

  Future<void> getImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile == null) {
      return;
    }
    setState(() {
      // ↓imageFileにカメラで撮影した写真をリストとして渡す
      final imageFile = <File>[File(pickedFile.path)];
      widget.addImageFiles(imageFile.toList());
    });
    Navigator.pop(context);
  }
}
