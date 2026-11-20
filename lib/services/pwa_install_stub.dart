import 'pwa_install_client.dart';

class _StubPwaInstallClient implements PwaInstallClient {
  @override
  bool get canInstall => false;

  @override
  void triggerInstall() {}

  @override
  void setOnInstalled(void Function()? callback) {}
}

PwaInstallClient createPwaInstallClient() => _StubPwaInstallClient();
