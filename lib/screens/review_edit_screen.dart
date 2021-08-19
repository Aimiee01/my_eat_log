import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_eat_log/review.dart';
import '../item_update_button.dart';
import 'item_delete_button.dart';

class ReviewEditScreen extends StatefulWidget {
  const ReviewEditScreen({
    Key? key,
    // docとして受け取り
    required this.reviewDoc,
  }) : super(key: key);

  /// 値受け取り用の変数
  final QueryDocumentSnapshot<Review> reviewDoc;

  @override
  _ReviewEditScreenState createState() => _ReviewEditScreenState();
}

class _ReviewEditScreenState extends State<ReviewEditScreen> {
  final _shopNameController = TextEditingController();
  final _menuNameController = TextEditingController();
  late TextEditingController _commentController;
  // 初期値は空なので？（lateは使えない）
  File? imageFile;

  Future<void> getImage() async {
    // 修正してもらった部分
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) {
      return;
    }
    setState(() {
      imageFile = File(pickedFile.path);
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

    // コメントを更新したいとき（reference は参照）
    // widget.reviewDoc.reference.update({'comment': ''});

    return Scaffold(
      appBar: AppBar(
        title: const Text('編集画面'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              SizedBox(
                width: 200,
                child: Container(
                  child: imageFile == null
                      ? const Center(child: Text('画像を選択してください'))
                      : Image.file(imageFile!),
                ),
              ),
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
                child: Expanded(
                  flex: 1,
                  child: TextFormField(
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
                ),
              ),
              Expanded(
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
              Expanded(
                flex: 4,
                child: TextFormField(
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
              ),
              ItemUpdateButton(
                _shopNameController,
                _menuNameController,
                _commentController,
                _formKey,
                widget.reviewDoc,
                imageFile,
              ),
              ItemDeleteButton(widget.reviewDoc),
            ],
          ),
        ),
      ),
    );
  }
}
