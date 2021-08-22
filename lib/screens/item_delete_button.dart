import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../review.dart';

class ItemDeleteButton extends StatelessWidget {
  const ItemDeleteButton(this.reviewDoc, {Key? key}) : super(key: key);
  final QueryDocumentSnapshot<Review> reviewDoc;

  @override
  Widget build(BuildContext context) {
    Future<void> deleteReview(BuildContext context) async {
      await reviewsRef.doc(reviewDoc.id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('削除されました'),
        ),
      );
    }

    return ElevatedButton(
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('削除してもいいですか？'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, 'キャンセル'),
                child: const Text('キャンセル')),
            TextButton(
                onPressed: () async {
                  await deleteReview(context);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('OK')),
          ],
        ),
      ),
      style: ElevatedButton.styleFrom(
          primary: Colors.redAccent, onPrimary: Colors.white),
      child: const Text(
        '削除',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}