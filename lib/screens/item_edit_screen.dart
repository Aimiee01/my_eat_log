import 'package:flutter/material.dart';
import 'package:my_eat_log/review.dart';

class ItemEditScreen extends StatefulWidget {
  const ItemEditScreen({Key? key}) : super(key: key);

  @override
  _ItemEditScreenState createState() => _ItemEditScreenState();
}

class _ItemEditScreenState extends State<ItemEditScreen> {
  final _shopNameController = TextEditingController();
  final _menuNameController = TextEditingController();
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // String get _text =>
  //     '${_shopNameController.text} : ${_menuNameController.text}';

// 画面遷移したらいらないので破棄
  @override
  void dispose() {
    _shopNameController.dispose();
    _menuNameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('編集画面')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Form(
                key: _formKey,
                child: Expanded(
                  flex: 1,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '登録したいお店の名前を入力してください';
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
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('評価'),
                    Text(
                      '★★★★☆',
                      style: TextStyle(fontSize: 20, color: Colors.yellow[800]),
                    ),
                  ],
                ),
              ),
              ItemAddButton(
                _shopNameController,
                _menuNameController,
                _commentController,
                _formKey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
