import 'pwa_install_stub.dart'
    if (dart.library.js_interop) 'pwa_install_web.dart' as impl;

/// Abstraction for triggering and observing web PWA installation.
abstract class PwaInstallClient {
  bool get canInstall;

  void triggerInstall();

  void setOnInstalled(void Function()? callback);
}

PwaInstallClient createPwaInstallClient() => impl.createPwaInstallClient();
