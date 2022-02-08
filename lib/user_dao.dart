import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserDao extends ChangeNotifier {
  final auth = FirebaseAuth.instance;

  /// user がログインしている場合 true を返す
  bool isLoggedIn() {
    return auth.currentUser != null;
  }

  /// user の ID を返す
  String? userId() {
    return auth.currentUser?.uid;
  }

  /// user の Emailアドレスを返す
  String? email() {
    return auth.currentUser?.email;
  }

  /// user のアカウント作成
  void signup(String email, String password) async {
    try {
      /// Firebaseのメソッドを呼び出し、新規アカウントを作成
      await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      /// user がログイン状態であることを全てのリスナーに通知
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      /// error処理
      if (e.code == 'weak-password') {
        print('脆弱なパスワードです');
      } else if (e.code == 'email-already-in-use') {
        print('すでに使用されているアドレスです');
      }
    } catch (e) {
      print(e);
    }
  }

  /// login
  void login(String email, String password) async {
    try {
      // Firebaseのメソッドを呼び出し、user のアカウントにログインする
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      /// error処理
      if (e.code == 'weak-password') {
        print('脆弱なパスワードです');
      } else if (e.code == 'email-already-in-use') {
        print('すでに使用されているアドレスです');
      }
    } catch (e) {
      print(e);
    }
  }

  /// logout
  void logout() async {
    await auth.signOut();
    notifyListeners();
  }
}
