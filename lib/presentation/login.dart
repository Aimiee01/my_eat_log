import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../user_dao.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();

  /// パスワード
  final _passwordController = TextEditingController();

  /// フォームに必要なキーを作成
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override

  /// controllerを破棄
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provider を使用して userDao のインスタンスを取得
    final userDao = Provider.of<UserDao>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('my Eat log'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),

        /// GlobalKeyを持つFormを作成)
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              const SizedBox(height: 80),
              Expanded(
                /// メールアドレスのフィールド
                child: TextFormField(
                  decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      hintText: 'Email Address'),
                  autofocus: false,

                  /// mailAddress のキーボードタイプを使用
                  keyboardType: TextInputType.emailAddress,

                  /// 自動修正と大文字変換をOFFにする
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,

                  /// 入力したemailの編集用コントローラーを設定
                  controller: _emailController,

                  /// 空文字列をチェックするバリデーターを定義
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'メールアドレスが入力されていません';
                    }
                    return null;
                  },
                ),
              ),
              Row(
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                          border: UnderlineInputBorder(), hintText: 'Password'),
                      autofocus: false,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      textCapitalization: TextCapitalization.none,
                      autocorrect: false,
                      controller: _passwordController,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'パスワードが入力されていません';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // ログインボタン
              Row(
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        /// 最初のボタンがloginメソッドを呼び出すよう設定
                        userDao.login(
                            _emailController.text, _passwordController.text);
                      },
                      child: const Text('ログイン'),
                    ),
                  ),
                ],
              ),
              // サインアップボタン
              Row(
                children: [
                  const SizedBox(height: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        /// signUpメソッドを呼び出すよう設定
                        userDao.signup(
                            _emailController.text, _passwordController.text);
                      },
                      child: const Text('新規作成'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
