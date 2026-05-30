import 'package:firebase_auth/firebase_auth.dart';
import '../errors/failures.dart';

/// Converts Firebase error codes to user-friendly Turkish messages
class FirebaseErrorHandler {
  FirebaseErrorHandler._();

  static AuthFailure handleAuthError(FirebaseAuthException e) {
    final message = _getAuthMessage(e.code);
    return AuthFailure(message, code: e.code.hashCode);
  }

  static String _getAuthMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı';
      case 'wrong-password':
        return 'Hatalı şifre girdiniz';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanılıyor';
      case 'weak-password':
        return 'Şifre çok zayıf, daha güçlü bir şifre seçin';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı, lütfen daha sonra tekrar deneyin';
      case 'operation-not-allowed':
        return 'Bu işlem izin verilmiyor';
      case 'network-request-failed':
        return 'İnternet bağlantısı bulunamadı';
      case 'invalid-credential':
        return 'Geçersiz kimlik bilgileri';
      case 'requires-recent-login':
        return 'Bu işlem için yeniden giriş yapmanız gerekiyor';
      default:
        return 'Bir hata oluştu, lütfen tekrar deneyin';
    }
  }
}
