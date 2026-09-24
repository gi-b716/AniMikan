#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <stdio.h>
#include <windows.h>

#include <string>

#include "app_links/app_links_plugin_c_api.h"
#include "flutter_window.h"
#include "utils.h"

namespace {

constexpr wchar_t kUrlScheme[] = L"animikan";

bool CarriesAppLink(const wchar_t* command_line) {
  if (command_line == nullptr) {
    return false;
  }
  const std::wstring prefix = std::wstring(kUrlScheme) + L"://";
  return ::wcsstr(command_line, prefix.c_str()) != nullptr;
}

void RegisterUrlProtocol() {
  wchar_t exe[MAX_PATH] = {};
  if (::GetModuleFileNameW(nullptr, exe, MAX_PATH) == 0) {
    return;
  }

  wchar_t command[MAX_PATH + 8] = {};
  if (::swprintf_s(command, L"\"%s\" \"%%1\"", exe) < 0) {
    return;
  }

  wchar_t classes_key[128] = {};
  wchar_t command_key[160] = {};
  if (::swprintf_s(classes_key, L"Software\\Classes\\%s", kUrlScheme) < 0 ||
      ::swprintf_s(command_key, L"%s\\shell\\open\\command", classes_key) < 0) {
    return;
  }

  wchar_t current[MAX_PATH + 8] = {};
  DWORD size = sizeof(current);
  if (::RegGetValueW(HKEY_CURRENT_USER, command_key, nullptr, RRF_RT_REG_SZ,
                     nullptr, current, &size) == ERROR_SUCCESS &&
      ::wcscmp(current, command) == 0) {
    return;
  }

  HKEY key = nullptr;
  if (::RegCreateKeyExW(HKEY_CURRENT_USER, classes_key, 0, nullptr, 0,
                        KEY_SET_VALUE, nullptr, &key, nullptr) !=
      ERROR_SUCCESS) {
    return;
  }

  ::RegSetKeyValueW(key, nullptr, L"URL Protocol", REG_SZ, L"", sizeof(L""));
  ::RegSetKeyValueW(key, nullptr, nullptr, REG_SZ, L"URL:AniMikan",
                    sizeof(L"URL:AniMikan"));
  ::RegCloseKey(key);

  if (::RegCreateKeyExW(HKEY_CURRENT_USER, command_key, 0, nullptr, 0,
                        KEY_SET_VALUE, nullptr, &key, nullptr) !=
      ERROR_SUCCESS) {
    return;
  }
  ::RegSetKeyValueW(
      key, nullptr, nullptr, REG_SZ, command,
      static_cast<DWORD>((::wcslen(command) + 1) * sizeof(wchar_t)));
  ::RegCloseKey(key);
}

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  if (CarriesAppLink(command_line) && SendAppLinkToInstance()) {
    return EXIT_SUCCESS;
  }

  RegisterUrlProtocol();

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"AniMikan", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
