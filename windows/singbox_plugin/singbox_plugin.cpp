#include "singbox_plugin.h"
#include <windows.h>
#include <string>
#include <fstream>
#include <flutter/method_result_functions.h>

namespace {

class SingBoxPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistry* registry) {
    auto channel = std::make_unique<flutter::MethodChannel<>>(
        registry->messenger(), "vpn/singbox",
        &flutter::StandardMethodCodec::GetInstance());

    auto plugin = std::make_unique<SingBoxPlugin>();

    channel->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto& call, auto result) {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registry->AddPlugin(std::move(plugin));
  }

  SingBoxPlugin() {}

  virtual ~SingBoxPlugin() {}

 private:
  void HandleMethodCall(
      const flutter::MethodCall<>& method_call,
      std::unique_ptr<flutter::MethodResult<>> result) {
    const std::string& method = method_call.method_name();

    if (method == "startVpn") {
      StartVpn(method_call, std::move(result));
    } else if (method == "stopVpn") {
      StopVpn(method_call, std::move(result));
    } else {
      result->NotImplemented();
    }
  }

  void StartVpn(
      const flutter::MethodCall<>& method_call,
      std::unique_ptr<flutter::MethodResult<>> result) {
    std::string config = std::get<std::string>(*method_call.arguments());

    // Écrivez la configuration dans un fichier temporaire
    std::string configPath = std::tmpnam(nullptr);
    std::ofstream configFile(configPath);
    configFile << config;
    configFile.close();

    // Chemin vers le binaire sing-box.exe
    std::wstring exePath = utils::GetExecutableDirectory();
    std::wstring singBoxPath = exePath + L"\\resources\\sing-box\\sing-box-amd64.exe";

    // Commande pour démarrer sing-box
    std::wstring command = L"\"" + singBoxPath + L"\" run -c \"" + std::wstring(configPath.begin(), configPath.end()) + L"\"";

    // Utilisez CreateProcess pour exécuter sing-box.exe
    STARTUPINFO si;
    PROCESS_INFORMATION pi;
    ZeroMemory(&si, sizeof(si));
    ZeroMemory(&pi, sizeof(pi));

    if (CreateProcess(
        NULL,
        const_cast<wchar_t*>(command.c_str()),
        NULL,
        NULL,
        FALSE,
        0,
        NULL,
        NULL,
        &si,
        &pi)) {
      result->Success(flutter::EncodableValue(true));
    } else {
      result->Error("Failed to start VPN", "CreateProcess failed");
    }
  }

  void StopVpn(
      const flutter::MethodCall<>& method_call,
      std::unique_ptr<flutter::MethodResult<>> result) {
    // Arrêtez sing-box.exe
    system("taskkill /f /im sing-box.exe");
    result->Success(flutter::EncodableValue(true));
  }
};

}  // namespace

void SingBoxPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  SingBoxPlugin::RegisterWithRegistrar(
      flutter::PluginRegistry::GetInstance()->registrar_for_plugin(
          "SingBoxPlugin", registrar));
}
