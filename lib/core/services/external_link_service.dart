import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_logger.dart';

/// Opens URLs, mail, dialer and the system share sheet.
///
/// Wrapping the plugins keeps widgets free of platform calls and lets tests
/// substitute a fake.
abstract interface class ExternalLinkService {
  Future<bool> openUrl(String url);
  Future<bool> sendEmail(String email, {String? subject});
  Future<bool> call(String phoneNumber);
  Future<void> share(String text, {String? subject});
}

class PlatformExternalLinkService implements ExternalLinkService {
  const PlatformExternalLinkService();

  @override
  Future<bool> openUrl(String url) =>
      _launch(Uri.parse(url), LaunchMode.externalApplication);

  @override
  Future<bool> sendEmail(String email, {String? subject}) => _launch(
    Uri(
      scheme: 'mailto',
      path: email,
      query: subject == null ? null : 'subject=${Uri.encodeComponent(subject)}',
    ),
  );

  @override
  Future<bool> call(String phoneNumber) => _launch(
    Uri(scheme: 'tel', path: phoneNumber.replaceAll(RegExp(r'\s'), '')),
  );

  @override
  Future<void> share(String text, {String? subject}) async {
    await SharePlus.instance.share(ShareParams(text: text, subject: subject));
  }

  Future<bool> _launch(
    Uri uri, [
    LaunchMode mode = LaunchMode.platformDefault,
  ]) async {
    try {
      final opened = await launchUrl(uri, mode: mode);
      if (!opened) AppLogger.warning('Could not open $uri');
      return opened;
    } on Object catch (error) {
      AppLogger.warning('Could not open $uri', error: error);
      return false;
    }
  }
}

final externalLinkServiceProvider = Provider<ExternalLinkService>(
  (ref) => const PlatformExternalLinkService(),
);
