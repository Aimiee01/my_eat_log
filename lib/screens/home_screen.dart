import 'package:flutter/material.dart';
import 'package:my_eat_log/screens/favorite_screen.dart';
import 'package:my_eat_log/setting_screen.dart';
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
        title: const Text('MyLog'),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      // (_)使わないので省略
                      builder: (_) => const FavoriteScreen(),
                    ),
                  ),
              icon: const Icon(Icons.favorite))
        ],
        leading: IconButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              // (_)使わないので省略
              builder: (_) => const SettingScreen(),
            ),
          ),
          icon: const Icon(Icons.settings),
        ),
      ),
      body: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return MyLogItem(
              title: 'shopName',
              subTitle: 'menuName',
              titleColor: Colors.blue,
              leading: Image.asset('assets/images/pizza/jpg'),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return const SizedBox(height: 10);
          },
          itemCount: 30),
    );
  }
}



class MyLogItem extends StatelessWidget {
  const MyLogItem(
      {required this.title,
      required this.subTitle,
      required this.leading,
      required this.titleColor});

  final String title;
  final String subTitle;
  final Widget leading;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ListTile(
        trailing: const Icon(Icons.favorite),
        leading: SizedBox(
          width: 60,
          height: 60,
          child: Image.asset('assets/images/pizza.jpg'),
        ),
        title: const Text('shop name'),
        subtitle: const Text('menu name'),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const ItemEditScreen(),
          ),
        ),
      ),
    );
  }
}
