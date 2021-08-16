import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_eat_log/review.dart';

class ItemAddButton extends StatelessWidget {
  const ItemAddButton(
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
    Future<void> addItem() async {
      if (globalKey.currentState!.validate()) {
        return reviewsRef
            .add(Review(
              shopName: shopNameController.text,
              menuName: menuNameController.text,
              comment: commentController.text,
            ))
            .then((value) => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('登録されました'))));
      }
    }

    return ElevatedButton(
      onPressed: () async {
        await addItem();
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
          primary: Colors.blue, onPrimary: Colors.white),
      child: const Text(
        '登録',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}