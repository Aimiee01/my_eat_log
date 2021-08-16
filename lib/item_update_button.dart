import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_eat_log/review.dart';

class ItemUpdateButton extends StatelessWidget {
  const ItemUpdateButton(
    this.shopNameController,
    this.menuNameController,
    this.commentController,
    this.globalKey,
  );
  final TextEditingController shopNameController;
  final TextEditingController menuNameController;
  final TextEditingController commentController;

  // <FormState>を必ず入れる(ジェネリクス)
  final GlobalKey<FormState> globalKey;
  @override
  Widget build(BuildContext context) {
    Future<void> updateItem() async {
      if (globalKey.currentState!.validate()) {
        return reviewsRef
            .add(
              Review(
              shopName: shopNameController.text,
              menuName: menuNameController.text,
              comment: commentController.text,
            ))
            .then((value) => ScaffoldMessenger.of(context)
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