import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SecretCodeService {
  static const int _codeLength = 6;

  /// Generate a unique 6-digit numeric secret code
  static String generateSecretCode({required String role}) {
    final random = Random.secure();
    final code = random.nextInt(1000000); // 0 to 999999
    return code.toString().padLeft(_codeLength, '0');
  }

  /// Validate secret code format (exactly 6 numeric digits)
  static bool isValidSecretCodeFormat(String code) {
    if (code.length != _codeLength) return false;

    // Check if all characters are digits
    for (var i = 0; i < code.length; i++) {
      if (!RegExp(r'\d').hasMatch(code[i])) {
        return false;
      }
    }

    return true;
  }

  /// Extract role from secret code
  /// Note: Since we now use 6-digit codes without prefixes, role is determined
  /// from the user account in Firebase, not from the code itself
  static String? getRoleFromSecretCode(String code) {
    // Role is now determined from the user's account, not the code
    return null;
  }

  /// Generate a hash of the secret code for secure storage comparison
  /// Note: For additional security, consider using a proper hashing algorithm
  /// with salt in production. This is a basic implementation.
  static String hashSecretCode(String code) {
    final bytes = utf8.encode(code);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
}
