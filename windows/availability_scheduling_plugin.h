#ifndef FLUTTER_PLUGIN_AVAILABILITY_SCHEDULING_PLUGIN_H_
#define FLUTTER_PLUGIN_AVAILABILITY_SCHEDULING_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace availability_scheduling {

class AvailabilitySchedulingPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  AvailabilitySchedulingPlugin();

  virtual ~AvailabilitySchedulingPlugin();

  // Disallow copy and assign.
  AvailabilitySchedulingPlugin(const AvailabilitySchedulingPlugin&) = delete;
  AvailabilitySchedulingPlugin& operator=(const AvailabilitySchedulingPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace availability_scheduling

#endif  // FLUTTER_PLUGIN_AVAILABILITY_SCHEDULING_PLUGIN_H_
