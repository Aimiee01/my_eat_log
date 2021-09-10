import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddTextfieldsView extends StatefulWidget {
  const AddTextfieldsView({
    Key? key,
    required this.formKey,
    required this.shopNameController,
    required this.menuNameController,
    required this.commentController,
  }) : super(key: key);

  final GlobalKey<FormState> formKey;
  final TextEditingController shopNameController;
  final TextEditingController menuNameController;
  final TextEditingController commentController;

  @override
  _AddTextfieldsViewState createState() => _AddTextfieldsViewState();
}

class _AddTextfieldsViewState extends State<AddTextfieldsView> {
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
