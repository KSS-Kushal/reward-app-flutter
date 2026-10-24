import 'package:flutter/foundation.dart';

/// What we receive from Google Sign-In. Only [idToken] is sent to the
/// backend, which must verify it with Google before issuing a session.
@immutable
class GoogleCredential {
  const GoogleCredential({
    required this.idToken,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  final String idToken;
  final String email;
  final String? displayName;
  final String? photoUrl;
}
