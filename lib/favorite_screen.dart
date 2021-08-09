import 'package:flutter/material.dart';
import 'home_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('favorite'),
      ),
      body: ListView(
        children: [
          MyLogItem(
            title: 'shop name',
            subTitle: 'item name',
            titleColor: Colors.blue,
            leading: Image.asset('assets/images/pizza/jpg'),
          ),
        ],
      ),
    );
  }
}
