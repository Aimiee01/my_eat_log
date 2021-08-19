import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_eat_log/review.dart';

class ItemUpdateButton extends StatelessWidget {
  ItemUpdateButton(
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
  Widget build(BuildContext context) {
    Future<void> updateItem() async {
      if (globalKey.currentState!.validate()) {
        return reviewsRef.doc(reviewDoc.id).update({
          'shopName': shopNameController.text,
          'menuName': menuNameController.text,
          'comment': commentController.text,
          'imageUrl': imageFile,
        }).then((value) => ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('更新されました'))));
      }
    }

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
