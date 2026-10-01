// preferred-mic: keep a preferred microphone as the default input whenever it
// is connected. macOS switches input to Bluetooth headsets (AirPods, Bose) when
// they connect; this listens for device and default-input changes and switches
// back. When the preferred mic is absent, macOS picks the default as usual.
//
// Usage: preferred-mic [name-prefix]   (default: "Shure MV7")

import CoreAudio
import Foundation

let preferredPrefix = CommandLine.arguments.dropFirst().first ?? "Shure MV7"
let system = AudioObjectID(kAudioObjectSystemObject)

func address(_ selector: AudioObjectPropertySelector,
             _ scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal) -> AudioObjectPropertyAddress {
  AudioObjectPropertyAddress(mSelector: selector, mScope: scope, mElement: kAudioObjectPropertyElementMain)
}

func log(_ message: String) {
  let timestamp = ISO8601DateFormatter().string(from: Date())
  print("\(timestamp) \(message)")
  fflush(stdout)
}

func deviceIDs() -> [AudioDeviceID] {
  var addr = address(kAudioHardwarePropertyDevices)
  var size: UInt32 = 0
  guard AudioObjectGetPropertyDataSize(system, &addr, 0, nil, &size) == noErr else { return [] }
  var ids = [AudioDeviceID](repeating: 0, count: Int(size) / MemoryLayout<AudioDeviceID>.size)
  guard AudioObjectGetPropertyData(system, &addr, 0, nil, &size, &ids) == noErr else { return [] }
  return ids
}

func name(of device: AudioDeviceID) -> String? {
  var addr = address(kAudioObjectPropertyName)
  var name: Unmanaged<CFString>?
  var size = UInt32(MemoryLayout<Unmanaged<CFString>?>.size)
  guard AudioObjectGetPropertyData(device, &addr, 0, nil, &size, &name) == noErr else { return nil }
  return name?.takeRetainedValue() as String?
}

func hasInput(_ device: AudioDeviceID) -> Bool {
  var addr = address(kAudioDevicePropertyStreams, kAudioObjectPropertyScopeInput)
  var size: UInt32 = 0
  return AudioObjectGetPropertyDataSize(device, &addr, 0, nil, &size) == noErr && size > 0
}

func defaultInput() -> AudioDeviceID {
  var addr = address(kAudioHardwarePropertyDefaultInputDevice)
  var id = AudioDeviceID(0)
  var size = UInt32(MemoryLayout<AudioDeviceID>.size)
  AudioObjectGetPropertyData(system, &addr, 0, nil, &size, &id)
  return id
}

func setDefaultInput(_ device: AudioDeviceID) -> OSStatus {
  var addr = address(kAudioHardwarePropertyDefaultInputDevice)
  var id = device
  return AudioObjectSetPropertyData(system, &addr, 0, nil, UInt32(MemoryLayout<AudioDeviceID>.size), &id)
}

func enforce() {
  guard let preferred = deviceIDs().first(where: {
    hasInput($0) && (name(of: $0)?.lowercased().hasPrefix(preferredPrefix.lowercased()) ?? false)
  }) else { return }

  let current = defaultInput()
  guard current != preferred else { return }

  let status = setDefaultInput(preferred)
  let from = name(of: current) ?? "unknown"
  let to = name(of: preferred) ?? preferredPrefix
  if status == noErr {
    log("Switched input from \(from) to \(to)")
  } else {
    log("Failed to switch input to \(to) (OSStatus \(status))")
  }
}

let queue = DispatchQueue(label: "preferred-mic")
let listener: AudioObjectPropertyListenerBlock = { _, _ in
  // Bluetooth devices can grab the default a moment after they appear, so
  // check again shortly after each change too.
  enforce()
  queue.asyncAfter(deadline: .now() + 1) { enforce() }
}

for selector in [kAudioHardwarePropertyDevices, kAudioHardwarePropertyDefaultInputDevice] {
  var addr = address(selector)
  AudioObjectAddPropertyListenerBlock(system, &addr, queue, listener)
}

log("Watching for input devices named \"\(preferredPrefix)*\"")
queue.async { enforce() }
dispatchMain()
