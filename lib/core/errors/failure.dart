/// Typed failures. UI maps each variant to an Arabic message from l10n.
sealed class Failure {
  const Failure();
}

/// The SQLite build has no cipher support (PRAGMA cipher returned nothing).
final class EncryptionUnavailable extends Failure {
  const EncryptionUnavailable();
}

/// The database could not be read with the supplied key.
final class EncryptionKeyRejected extends Failure {
  const EncryptionKeyRejected();
}
