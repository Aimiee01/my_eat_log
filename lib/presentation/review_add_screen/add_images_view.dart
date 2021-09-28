import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddImagesView extends StatefulWidget {
  const AddImagesView({
    Key? key,
    required this.imageFileList,
  }) : super(key: key);

  final List<File> imageFileList;

  @override
  _AddImagesViewState createState() => _AddImagesViewState();
}

class _AddImagesViewState extends State<AddImagesView> {
  @override
  Widget build(BuildContext context) {
    /// ユーザーが選択したデバイスの写真ファイル
    final imageFileList = widget.imageFileList;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        width: 350,
        height: 70,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: imageFileList.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              // 写真の前にタップ可能なTextButtonを配置
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
            // ボタンの分indexから-1した[imageFileIndex]を作成
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
                              child: const Text('キャンセル')),
                          TextButton(
                              style: TextButton.styleFrom(
                                primary: Colors.redAccent,
                              ),
                              onPressed: () {
                                setState(() {
                                  // 削除する写真を指定するときは
                                  // 新しい[imageFileIndex]を使うこと
                                  imageFileList.removeAt(imageFileIndex);
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('削除')),
                        ],
                      );
                    });
              },

              // タッチ検出対象のWidget
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Image.file(imageFile),
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

  /// ユーザーが写真を選択する
  Future<void> selectImagesButton() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles == null || pickedFiles.isEmpty) {
      return;
    }
    setState(() {
      /// ImagePickerで選択された複数枚の写真
      final files = pickedFiles.map((pickedFile) => File(pickedFile.path));
      widget.imageFileList.addAll(files);
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
      final imageFile = File(pickedFile.path);
      widget.imageFileList.add(imageFile);
    });
    Navigator.pop(context);
  }
}
