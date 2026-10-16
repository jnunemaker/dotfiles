// preferred-mic: keep a preferred microphone as the default input whenever it
// is connected. macOS switches input to Bluetooth headsets (AirPods, Bose) when
// they connect; this listens for device and default-input changes and switches
// back.
//
// When the preferred mic is absent, it still keeps input off Bluetooth
// headphones. Using their mic drops them from stereo music into low-quality
// headset audio, so it switches to the MacBook's mic (when the lid is open) or
// a wired mic like a monitor's instead. With no other mic around, it leaves the
// Bluetooth mic alone, and closing the lid with nothing else connected moves
// input back to it rather than leaving the muted MacBook mic selected.
//
// Usage: preferred-mic [name-prefix]   (default: "Shure MV7")

import CoreAudio
import Foundation
import IOKit

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

func uint32Property(of device: AudioDeviceID, _ selector: AudioObjectPropertySelector,
                    _ scope: AudioObjectPropertyScope = kAudioObjectPropertyScopeGlobal) -> UInt32? {
  var addr = address(selector, scope)
  var value: UInt32 = 0
  var size = UInt32(MemoryLayout<UInt32>.size)
  guard AudioObjectGetPropertyData(device, &addr, 0, nil, &size, &value) == noErr else { return nil }
  return value
}

func transportType(of device: AudioDeviceID) -> UInt32 {
  uint32Property(of: device, kAudioDevicePropertyTransportType) ?? 0
}

let bluetoothTransports = [kAudioDeviceTransportTypeBluetooth, kAudioDeviceTransportTypeBluetoothLE]
// Physically connected mics. Leaves out virtual, aggregate, AirPlay, and
// Continuity (iPhone) devices.
let wiredTransports = [kAudioDeviceTransportTypeUSB, kAudioDeviceTransportTypeFireWire,
                       kAudioDeviceTransportTypeThunderbolt, kAudioDeviceTransportTypePCI,
                       kAudioDeviceTransportTypeHDMI, kAudioDeviceTransportTypeDisplayPort,
                       kAudioDeviceTransportTypeAVB]
let internalMicSource: UInt32 = 0x696D_6963 // 'imic'

func isBluetooth(_ device: AudioDeviceID) -> Bool {
  bluetoothTransports.contains(transportType(of: device))
}

// The MacBook's own mic. A headset on the headphone jack is also a built-in
// device, but reports an external data source and works with the lid closed.
func isInternalMic(_ device: AudioDeviceID) -> Bool {
  transportType(of: device) == kAudioDeviceTransportTypeBuiltIn &&
    uint32Property(of: device, kAudioDevicePropertyDataSource, kAudioObjectPropertyScopeInput) == internalMicSource
}

func isWired(_ device: AudioDeviceID) -> Bool {
  let type = transportType(of: device)
  return wiredTransports.contains(type) || (type == kAudioDeviceTransportTypeBuiltIn && !isInternalMic(device))
}

let powerRoot = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPMrootDomain"))

// The MacBook's mic is cut off while the lid is closed.
func lidClosed() -> Bool {
  let state = IORegistryEntryCreateCFProperty(powerRoot, "AppleClamshellState" as CFString, kCFAllocatorDefault, 0)
  return state?.takeRetainedValue() as? Bool ?? false
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

func switchInput(from current: AudioDeviceID, to device: AudioDeviceID) {
  guard current != device else { return }

  let status = setDefaultInput(device)
  let from = name(of: current) ?? "unknown"
  let to = name(of: device) ?? "unknown"
  if status == noErr {
    log("Switched input from \(from) to \(to)")
  } else {
    log("Failed to switch input to \(to) (OSStatus \(status))")
  }
}

func enforce() {
  let inputs = deviceIDs().filter(hasInput)
  let current = defaultInput()

  if let preferred = inputs.first(where: {
    name(of: $0)?.lowercased().hasPrefix(preferredPrefix.lowercased()) ?? false
  }) {
    switchInput(from: current, to: preferred)
    return
  }

  let closed = lidClosed()
  let currentMuted = closed && isInternalMic(current)
  guard isBluetooth(current) || currentMuted else { return }

  let internalMic = closed ? nil : inputs.first(where: isInternalMic)
  let wired = inputs.first(where: isWired)
  // A muted mic is worse than headset-quality audio, so Bluetooth is the last resort.
  let bluetooth = currentMuted ? inputs.first(where: isBluetooth) : nil
  if let fallback = internalMic ?? wired ?? bluetooth {
    switchInput(from: current, to: fallback)
  }
}

let queue = DispatchQueue(label: "preferred-mic")
func recheck() {
  // Bluetooth devices can grab the default a moment after they appear, so
  // check again shortly after each change too.
  enforce()
  queue.asyncAfter(deadline: .now() + 1) { enforce() }
}

for selector in [kAudioHardwarePropertyDevices, kAudioHardwarePropertyDefaultInputDevice] {
  var addr = address(selector)
  AudioObjectAddPropertyListenerBlock(system, &addr, queue) { _, _ in recheck() }
}

// Power events include opening and closing the lid.
let powerPort = IONotificationPortCreate(kIOMainPortDefault)
IONotificationPortSetDispatchQueue(powerPort, queue)
var powerNotifier: io_object_t = 0
IOServiceAddInterestNotification(powerPort, powerRoot, kIOGeneralInterest,
                                 { _, _, _, _ in recheck() }, nil, &powerNotifier)

log("Watching for input devices named \"\(preferredPrefix)*\"")
queue.async { enforce() }
dispatchMain()
