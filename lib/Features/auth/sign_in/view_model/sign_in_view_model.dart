import 'package:flutter/material.dart';
import '../../repository/auth_repository.dart';

class SignInViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signIn() async {
    if (emailController.text.trim().isEmpty) {
      _errorMessage = 'Please enter your email';
      notifyListeners();
      return false;
    }

    if (passwordController.text.isEmpty) {
      _errorMessage = 'Please enter your password';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _authRepository.resetPassword(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

