import 'package:firebase_auth/firebase_auth.dart' show User, FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../widgets/floating_snackbar.dart';

class NewsAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final getStorageInstance = GetStorage();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _userName;
  String? get userName => _userName;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // SIGN UP
  Future<bool> signUp({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
  }) async {
    setLoading(true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await cred.user!.updateDisplayName(name);

      _userName = name;
      getStorageInstance.write('user_name', name);

      await _saveToken();

      showSnack(context, "Account created!!!");

      return true; //success
    } catch (e) {
      showSnack(context, e.toString());
      return false; //failure
    } finally {
      setLoading(false);
    }
  }

  // SIGN IN
  Future<User?> signIn(String email, String password) async {}

  Future<void> _saveToken() async {
    final token = await _auth.currentUser?.getIdToken();
    getStorageInstance.write('token', token);
  }

  String? get userEmail => _auth.currentUser?.email;

  // LOGOUT
  Future<void> logout(BuildContext context) async {
    await _auth.signOut();
    getStorageInstance.erase();
    _userName = null;
    notifyListeners();
    showSnack(context, "Logged out");
  }
}
