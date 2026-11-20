import 'dart:js_interop';
import 'pwa_install_client.dart';

@JS('quickFdrPwaCanShow')
external bool _jsCanShow();

@JS('quickFdrPwaTriggerInstall')
external void _jsTriggerInstall();

@JS('quickFdrPwaSetOnInstalled')
external void _jsSetOnInstalled(JSFunction? callback);

class _WebPwaInstallClient implements PwaInstallClient {
  @override
  bool get canInstall {
    try {
      return _jsCanShow();
    } catch (_) {
      return false;
    }
  }

  @override
  void triggerInstall() {
    try {
      _jsTriggerInstall();
    } catch (_) {}
  }

  @override
  void setOnInstalled(void Function()? callback) {
    try {
      _jsSetOnInstalled(callback?.toJS);
    } catch (_) {}
  }
}

PwaInstallClient createPwaInstallClient() => _WebPwaInstallClient();
