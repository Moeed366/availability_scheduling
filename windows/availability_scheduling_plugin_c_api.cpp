#include "include/availability_scheduling/availability_scheduling_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "availability_scheduling_plugin.h"

void AvailabilitySchedulingPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  availability_scheduling::AvailabilitySchedulingPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
