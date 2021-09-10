import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_eat_log/domain/review/entities/review.dart';
import 'package:my_eat_log/domain/review/entities/review_image.dart';
import 'package:my_eat_log/domain/review/review_image_repository.dart';
import 'package:my_eat_log/domain/review/review_repository.dart';

class EditImagesView extends StatefulWidget {
  const EditImagesView({
    Key? key,
    required this.snapshot,
    required this.reviewDoc,
    required this.imageFileList,
    // 新しく選択された写真たち
    required this.addImageFiles,
    // 削除する写真たち
    required this.removeImageFile,
  }) : super(key: key);

  final QuerySnapshot<ReviewImage> snapshot;
  final QueryDocumentSnapshot<Review> reviewDoc;
  final List<File> imageFileList;
  final ValueChanged<List<File>> addImageFiles;
  final ValueChanged<int> removeImageFile;

  @override
  _EditImagesViewState createState() => _EditImagesViewState();
}

class _EditImagesViewState extends State<EditImagesView> {
  /// ユーザーが写真ギャラリーから写真を選択する
  /// 写真が選ばれたら `widget.imageFileList` に [File] が入る
  /// キャンセルされた場合は何もしない
  ///   /// ユーザーが選択したデバイスの写真ファイル
  File? imageFile;

  @override
  Widget build(BuildContext context) {
    final imageFileList = widget.imageFileList;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        width: 350,
        height: 70,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          // プラスボタンを表示するので2つのlengthの合計に+1する
          itemCount: widget.snapshot.docs.length + imageFileList.length + 1,

          itemBuilder: (context, index) {
            // 写真がどこにも存在しない場合+ボタンを表示
            if (index == 0) {
              return SizedBox(
                width: 115,
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
              // + があるから1を引く
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
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Image.file(imageFile),
                ),
              );
            }
            // 残りはアップロード済みの写真
            final docsIndex = index - (imageFileList.length + 1);
            final imageDoc = widget.snapshot.docs[docsIndex];
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
                        // FirebaseStorageに保存済みの写真を削除する
                        TextButton(
                          onPressed: () {
                            _onDeleteImageButton(
                              doc: imageDoc,
                              docs: widget.snapshot.docs,
                            );
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
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
                child: Image.network(imageDoc.data().storageUrl),
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

  /// アップロード済みの写真を削除する
  /// 削除された写真より前に登録した写真があれば
  /// latestImageUrlを更新する

  void _onDeleteImageButton({
    // 削除する写真のドキュメント
    required QueryDocumentSnapshot<ReviewImage> doc,
    // 全写真のリスト
    required List<QueryDocumentSnapshot<ReviewImage>> docs,
  }) {
    final data = doc.data();

    setState(() {
      ReviewImageRepository.instance.delete(
        data.storageUrl,
        storagePath: data.storagePath,
        imageDocId: doc.id,
        reviewId: widget.reviewDoc.id,
      );
    });
    debugPrint('docs.last.id == doc.id: ${docs.last.id == doc.id}');

    // 登録済みの最後の写真と削除された写真のIDを比較
    if (docs.last.id != doc.id) {
      // 削除した画像は最後の画像ではなかったので latestImageUrl を書き換える必要はない。
      // 早期リターンする
      return;
    }
    // 写真リストから削除された写真を取り除く
    docs.removeLast();

    // 最後の画像を削除していた場合
    if (docs.isEmpty) {
      // latestImageUrl: null にする
      ReviewRepository.instance.updateLatestImageUrl(
        null,
        reviewId: widget.reviewDoc.id,
      );
      return;
    }
    // 最後の画像を削除したが、まだ他に画像が残っている場合
    // 残っている画像のうち、最後の画像を latestImageUrl に設定する
    final lastDoc = docs.last;
    ReviewRepository.instance.updateLatestImageUrl(
      lastDoc.data().storageUrl,
      reviewId: widget.reviewDoc.id,
    );

    Navigator.pop(context);
  }
}
