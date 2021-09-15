import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_eat_log/domain/review/entities/review.dart';

class EditTextfieldsView extends StatefulWidget {
  const EditTextfieldsView({
    Key? key,
    required this.formKey,
    required this.reviewDoc,
    required this.shopNameController,
    required this.menuNameController,
    required this.commentController,
  }) : super(key: key);

  final GlobalKey<FormState> formKey;
  final QueryDocumentSnapshot<Review> reviewDoc;
  final TextEditingController shopNameController;
  final TextEditingController menuNameController;
  final TextEditingController commentController;

  @override
  _EditTextfieldsViewState createState() => _EditTextfieldsViewState();
}

class _EditTextfieldsViewState extends State<EditTextfieldsView> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          const SizedBox(height: 4),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
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
            controller: widget.shopNameController,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '品名を入力してください';
                }
                return null;
              },
              decoration: const InputDecoration(
                icon: Icon(Icons.fastfood),
                border: OutlineInputBorder(),
                labelText: '商品名 *',
              ),
              controller: widget.menuNameController,
            ),
          ),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '感想を入力してください';
              }
              return null;
            },
            decoration: const InputDecoration(
              icon: Icon(Icons.comment),
              border: OutlineInputBorder(),
              labelText: '感想 *',
            ),
            controller: widget.commentController,
            minLines: 4,
            maxLines: 8,
          ),
        ],
      ),
    );
  }
}
