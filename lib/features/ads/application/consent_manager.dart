import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Thin wrapper around Google's User Messaging Platform (UMP) consent SDK.
///
/// It requests the latest consent information on launch, shows the consent form
/// when required, and exposes whether ads may be requested and whether a
/// "Privacy options" button should appear in Settings.
class ConsentManager {
  bool _privacyOptionsRequired = false;

  bool get isPrivacyOptionsRequired => _privacyOptionsRequired;

  /// Requests consent info and shows the form if the SDK says it is required.
  /// Any failure is swallowed so a consent hiccup never blocks the app.
  Future<void> gatherConsent() async {
    try {
      final params = ConsentRequestParameters();
      final updated = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        updated.complete,
        (FormError error) {
          debugPrint('Consent info update failed: ${error.message}');
          if (!updated.isCompleted) updated.complete();
        },
      );
      await updated.future;

      final shown = Completer<void>();
      ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
        if (error != null) {
          debugPrint('Consent form error: ${error.message}');
        }
        if (!shown.isCompleted) shown.complete();
      });
      await shown.future;

      _privacyOptionsRequired = await _computePrivacyOptionsRequired();
    } catch (e) {
      debugPrint('ConsentManager.gatherConsent failed: $e');
    }
  }

  Future<bool> _computePrivacyOptionsRequired() async {
    try {
      final status = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      return status == PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      return false;
    }
  }

  Future<bool> canRequestAds() async {
    try {
      return await ConsentInformation.instance.canRequestAds();
    } catch (_) {
      return false;
    }
  }

  /// Shows the privacy options form (re-consent) from a Settings entry point.
  Future<void> showPrivacyOptionsForm() async {
    final done = Completer<void>();
    try {
      ConsentForm.showPrivacyOptionsForm((FormError? error) {
        if (error != null) {
          debugPrint('Privacy options form error: ${error.message}');
        }
        if (!done.isCompleted) done.complete();
      });
    } catch (e) {
      debugPrint('showPrivacyOptionsForm failed: $e');
      if (!done.isCompleted) done.complete();
    }
    await done.future;
    _privacyOptionsRequired = await _computePrivacyOptionsRequired();
  }
}
