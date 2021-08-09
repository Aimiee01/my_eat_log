import 'package:flutter/material.dart';
import 'package:my_eat_log/home_screen.dart';

class ItemEditScreen extends StatefulWidget {
  const ItemEditScreen({Key? key}) : super(key: key);

  @override
  _ItemEditScreenState createState() => _ItemEditScreenState();
}

class _ItemEditScreenState extends State<ItemEditScreen> {
  var _shopNameController = TextEditingController();
  var _itemNameController = TextEditingController();
  String get _text =>
      '${_shopNameController.text} : ${_itemNameController.text}';

// 画面遷移したらいらないので破棄
  @override
  void dispose() {
    _shopNameController.dispose();
    _itemNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('編集画面')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 1,
                child: TextFormField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.shopping_basket),
                    border: OutlineInputBorder(),
                    hintText: '登録したいお店の名前を入力してください',
                    labelText: 'お店の名前 *',
                  ),
                  controller: _shopNameController,
                ),
              ),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.shopping_cart_rounded),
                    border: OutlineInputBorder(),
                    hintText: '登録したい商品名を入力してください',
                    labelText: '商品名 *',
                  ),
                  controller: _itemNameController,
                ),
              ),
              Expanded(
                flex: 4,
                child: TextFormField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.shopping_cart_rounded),
                    border: OutlineInputBorder(),
                    hintText: '感想を入力してください',
                    labelText: '評価内容 *',
                  ),
                  minLines: 6,
                  maxLines: 10,
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('評価'),
                    Text(
                      '★★★★☆',
                      style:
                          TextStyle(fontSize: 20.0, color: Colors.yellow[800]),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                child: Text('登録'),
                onPressed: () {
                  setState(() {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const HomeScreen(),
                      ),
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
