import 'package:flutter/material.dart';
import 'package:my_eat_log/favorite_screen.dart';
import 'item_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyLog'),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      // (_)使わないので省略
                      builder: (_) => const FavoriteScreen(),
                    ),
                  ),
              icon: Icon(Icons.favorite))
        ],
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.settings),
        ),
      ),
      body: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return MyLogItem(
              title: 'name',
              subTitle: 'subtitle',
              titleColor: Colors.blue,
              leading: Image.asset('assets/images/pizza/jpg'),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(height: 10.0);
          },
          itemCount: 30),
    );
  }
}

class MyLogItem extends StatelessWidget {
  final String title;
  final String subTitle;
  final Widget leading;
  final Color titleColor;

  MyLogItem(
      {required this.title,
      required this.subTitle,
      required this.leading,
      required this.titleColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: ListTile(
          leading: SizedBox(
            child: Image.asset('assets/images/pizza.jpg'),
            width: 60.0,
            height: 60.0,
          ),
          title: Text('shop name'),
          subtitle: Text('menu name'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const ItemEditScreen(),
            ),
          ),
        ),
      ),
    );
  }
}
