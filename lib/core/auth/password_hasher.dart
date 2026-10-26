import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:radar_labor/core/constants/app_constants.dart';

/// Pure Dart Argon2id password hashing and constant-time verification.
final class PasswordHasher {
  const PasswordHasher();

  static final _argon2id = Argon2id(
    parallelism: AuthConstants.argon2Parallelism,
    memory: AuthConstants.argon2Memory,
    iterations: AuthConstants.argon2Iterations,
    hashLength: AuthConstants.hashByteLength,
  );

  Future<List<int>> hash(String password, List<int> salt) => Isolate.run(
    () async => (await _argon2id.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    )).extractBytes(),
  );

  /// Hashes [raw] with a fresh random salt; returns base64url `(salt, hash)`.
  Future<(String, String)> hashEncoded(String raw) async {
    final salt = randomBytes(AuthConstants.saltByteLength);
    final digest = await hash(raw, salt);
    return (base64UrlEncode(salt), base64UrlEncode(digest));
  }

  /// Verifies [raw] against base64url-encoded [salt] and [expectedHash].
  Future<bool> verifyEncoded(
    String raw, {
    required String salt,
    required String expectedHash,
  }) async {
    final candidate = await hash(raw, base64Url.decode(salt));
    return constantTimeEquals(candidate, base64Url.decode(expectedHash));
  }

  List<int> randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List.generate(length, (_) => random.nextInt(256)),
    );
  }

  bool constantTimeEquals(List<int> left, List<int> right) {
    if (left.length != right.length) return false;
    var difference = 0;
    for (var i = 0; i < left.length; i++) {
      difference |= left[i] ^ right[i];
    }
    return difference == 0;
  }
}
