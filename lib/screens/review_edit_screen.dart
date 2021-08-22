import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_eat_log/review.dart';
import 'item_delete_button.dart';

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
  final _shopNameController = TextEditingController();
  final _menuNameController = TextEditingController();
  late TextEditingController _commentController;
  // 初期値は空なので？（lateは使えない）
  File? _imageFile;

  // Future<void> downloadFile(String imagePath) async {
  //   final imageurl = widget.storage.ref().child('images/$imagePath');
  //   final String url = await ref.getDownloadURL();
  //   final img = Image(image: CacheNetworkImageProvider(url));
  // }

  /// ユーザーが写真ギャラリーから写真を選択する
  /// 写真が選ばれたら [_imageFile] に [File] が入る
  /// キャンセルされた場合は何もしない
  Future<void> getImage() async {
    // 修正してもらった部分
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return;
    }
    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }

  @override
  void initState() {
    super.initState();
    final review = widget.reviewDoc.data();
    // 2通りの書き方がある
    _shopNameController.value =
        _shopNameController.value.copyWith(text: review.shopName);
    _menuNameController.text = review.menuName;
    _commentController = TextEditingController(text: review.comment);
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final review = widget.reviewDoc.data();
    final imageUrl = review.imageUrl;

    // コメントを更新したいとき（reference は参照）
    // widget.reviewDoc.reference.update({'comment': ''});
    return Scaffold(
      appBar: AppBar(
        title: const Text('編集画面'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_imageFile != null)
                  Image.file(_imageFile!)
                else if (imageUrl != null)
                  Image.network(imageUrl)
                else
                  const Icon(Icons.image_outlined),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.blue[600]),
                    onPressed: getImage,
                    // 画像をカメラロールを開く
                    child: const Text('画像を追加'),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'お店の名前を入力してください';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          icon: Icon(Icons.food_bank_outlined),
                          border: OutlineInputBorder(),
                          labelText: 'お店の名前 *',
                        ),
                        controller: _shopNameController,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            icon: Icon(Icons.fastfood),
                            border: OutlineInputBorder(),
                            hintText: '登録したい商品名を入力してください',
                            labelText: '商品名 *',
                          ),
                          controller: _menuNameController,
                        ),
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          icon: Icon(Icons.comment),
                          border: OutlineInputBorder(),
                          hintText: '感想を入力してください',
                          labelText: '感想 *',
                        ),
                        controller: _commentController,
                        minLines: 6,
                        maxLines: 10,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: _ItemUpdateButton(
                    _shopNameController,
                    _menuNameController,
                    _commentController,
                    _formKey,
                    widget.reviewDoc,
                    _imageFile,
                  ),
                ),
                ItemDeleteButton(widget.reviewDoc),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemUpdateButton extends StatefulWidget {
  _ItemUpdateButton(
    this.shopNameController,
    this.menuNameController,
    this.commentController,
    this.globalKey,
    this.reviewDoc,
    this.imageFile, {
    Key? key,
  }) : super(key: key);

  final TextEditingController shopNameController;
  final TextEditingController menuNameController;
  final TextEditingController commentController;
  // <FormState>を必ず入れる(ジェネリクス)
  final GlobalKey<FormState> globalKey;
  final QueryDocumentSnapshot<Review> reviewDoc;

  File? imageFile;

  @override
  _ItemUpdateButtonState createState() => _ItemUpdateButtonState();
}

class _ItemUpdateButtonState extends State<_ItemUpdateButton> {
  @override
  Widget build(BuildContext context) {
    /// レビューを更新する
    Future<void> updateItem() async {
      String? imageUrl;
      String? imagePath;
      // 画像が選択されていればfirebase Storageに保存する
      if (widget.imageFile != null) {
        // timestampは画像がある時にしか使わないのでこの場所に書く
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        imagePath = 'user-id/menu-images/upload-pic-$timestamp.png';
        final imageRef = FirebaseStorage.instance.ref(imagePath);
        // Storageに画像を保存
        await imageRef.putFile(widget.imageFile!);
        // 保存した画像のURLを取得して、あらかじめ用意していた変数に入れる
        imageUrl = await imageRef.getDownloadURL();
      }
      await reviewsRef.doc(widget.reviewDoc.id).update({
        'shopName': widget.shopNameController.text,
        'menuName': widget.menuNameController.text,
        'comment': widget.commentController.text,
        if (imagePath != null) 'imagePath': imagePath,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }
          // imagePathにはファイル名を指定する
          ).then((value) => ScaffoldMessenger.of(
              context)
          .showSnackBar(const SnackBar(content: Text('更新されました'))));
    }
    // if (globalKey.currentState!.validate()) {
    //   return reviewsRef.doc(reviewDoc.id).

    return ElevatedButton(
      onPressed: () async {
        await updateItem();
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
          primary: Colors.blue, onPrimary: Colors.white),
      child: const Text(
        '更新',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}
