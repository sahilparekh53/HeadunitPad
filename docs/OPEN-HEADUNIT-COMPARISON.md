# Open Headunit comparison and iPad implementation

## Reference provenance

- Official source: https://github.com/andreknieriem/open-headunit
- Release: v.4.0.0, source commit `5511654d0d01ec72db34f94befbcebcab3f8af23`.
- Official release APK downloaded to the sibling workspace `analysis/open-headunit/`.
- APK SHA256: `5e6ac16c528d06a26b6ce764cf56a6e26dc72b70d45a4df1e64239c74e0db908`.
- APK triage: native Kotlin/Java; two DEX files; Android USB, video/audio and TLS native libraries across four ABIs. This is not a portable web or Flutter application.
- The installed Android Reverse Engineering skill guided fingerprinting and call-flow inspection. Full Java decompilation was unnecessary because the matching source is published. No claim of complete APK decompilation is made.
- Source is AGPL-3.0; retain attribution and corresponding source when distributing derivatives. The Swift changes here implement comparable behavior in the existing HeadunitPad codebase.

## Findings translated into the iPad app

| Behavior | Open Headunit source | iPad change |
|---|---|---|
| Last successful session | `main/AutoConnectFragment.kt`, `utils/Settings.kt` | Persist a successful direct phone endpoint; preserve helper discovery when the session is inbound. |
| Retry ownership | `aap/AutomaticReconnect.kt` | One retry timer; stale generations cannot restart a superseded or manually cancelled attempt. |
| Visible startup status and cancellation | `activity_main.xml`, `main/AutoConnectAttemptPolicy.kt` | Clear connection state, progress indicator and accessible Cancel button. |
| Reconnect after an interruption | Service-owned Android lifecycle | Resume the supported iPad flow on foreground; pause retries and scanning when inactive/backgrounded. |
| Touch-oriented home screen | Android native fragments and home layout | Native UIKit dashboard with large controls and full-screen projection. |
| Platform USB / Bluetooth / P2P | Android hardware and system APIs | Separate feasibility work; the wireless iPad release does not advertise unimplemented transports. |

The working Android Auto framing, TLS, H.264 rendering, audio and touch protocol are preserved. Release builds omit selected input, media-metadata and navigation console traces. A mini 4 preset selects landscape 720p, 30 FPS and phone GPS. These are code-level changes; no new performance benchmark on the physical iPad has been collected.

## Connection limits and next experiments

### Current supported wireless mode

Use the shared Wi-Fi network or S24 hotspot that already works. Connect once after upgrading to save a successful endpoint. Later launches try that address; failures fall back to discovery, and a newly discovered unknown endpoint still requires selection. Stop/Cancel suppresses automatic reconnection for that app session. The S24 must still make Android Auto's head unit server available.

### Native Wi-Fi Direct

The mini 4's iPadOS 15 public networking APIs do not provide Android's Wi-Fi Direct discovery/group-negotiation interface. Apple peer-to-peer Wi-Fi is not Android P2P, and newer Wi-Fi Aware APIs do not apply to this device. See Apple's [Wi-Fi API overview](https://developer.apple.com/documentation/technotes/tn3111-ios-wifi-api-overview).

A separate iPad transport can be developed, but native Android-compatible P2P is unproven on this hardware. TrollStore does not establish driver or protocol support. Possible future research includes an S24 companion acting as a P2P group owner with the iPad joining as a normal Wi-Fi client; that must be labelled a bridge, not native iPad P2P, and requires phone-side implementation and hardware testing.

### Wired USB feasibility

The mini 4 is compatible with Apple's [Lightning to USB 3 Camera Adapter](https://www.apple.com/shop/product/mx5j3am/a/lightning-to-usb-3-camera-adapter), including its external-power connection. A test would use a data-capable USB-A to USB-C cable to the S24 and may need a powered hub. A plain USB-C-to-Lightning charging cable is not a demonstrated USB-host setup.

Upstream HeadunitPad's wired path uses TrollUSBHostKit, AOA negotiation and private USB entitlements. The inspected package declares iOS 16 minimum; changing that declaration alone does not prove iOS 15 compatibility. A separate iOS 15 package build and a TrollStore-installed physical USB probe are required before enabling wired mode in the mini 4 release. The existing upstream proof is for a newer USB-C iPad, not this Lightning mini 4.

No wired or native-P2P support is claimed in this release. Keep the proven wireless build as the baseline while these transports are investigated.

## Hardware follow-up

The user currently has a USB-C-to-Lightning cable, not the powered Lightning camera adapter. That cable alone does not establish the proposed iPad-host / Android-accessory topology. USB hardware acceptance cannot run with the current cable alone.

UTM's [USB sharing documentation](https://docs.getutm.app/guest-support/sharing/usb/) documents exploit-enabled iOS USB access and explicitly names the Lightning to USB 3 Camera Adapter for Lightning devices. This supports investigating the transport, but is not proof that HeadunitPad's AOA path works on this mini 4.

The inspected TrollUSBHostKit source commit is `ecfd7fbc59ec340509d568da2400d7f0d94a892e`. It uses the UTM libusb fork and private IOKit USB user clients. A separately pinned, compiled iOS 15 consumer and a physical entitlement/enumeration/AOA test remain required.
