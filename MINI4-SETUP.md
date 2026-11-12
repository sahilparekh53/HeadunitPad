# HeadunitPad for iPad mini 4

Target hardware: iPad mini 4 running iPadOS 15.8.5 and Samsung Galaxy S24.
This variant uses wireless Android Auto. Device operation remains unverified
until it is installed and tested on that hardware.

## Build from Windows

1. Open your GitHub fork's Actions page and select **Build iPad mini 4**.
2. Open the run for the **mini4-wireless** branch. A branch push starts it
   automatically. The workflow builds on GitHub's Mac and uses the installed
   iOS Simulator Skill's build/test script there.
3. After every step passes, download **HeadunitPad-Mini4-iPadOS15-unsigned**
   from the run's Artifacts section and extract the ZIP.
4. The resulting `HeadunitPad-Mini4-unsigned.ipa` needs signing during
   installation; it cannot be installed simply by copying it to the iPad.

The newer simulator runtime checks app compilation and protocol/transport
tests. It does not prove compatibility with the physical mini 4 or iPadOS 15.
The device build enforces the iPadOS 15 deployment target separately.

## Install from Windows

Use [AltStore Classic's official Windows instructions](https://faq.altstore.io/altstore-classic/how-to-install-altstore-windows)
to install AltServer and AltStore, then import the unsigned IPA using the +
button in AltStore's My Apps tab. Complete Apple account authentication in
AltServer/AltStore itself. Ordinary free signing requires periodic refresh;
follow AltStore's expiry and refresh prompts. iPadOS 15 has no iOS 16 Developer
Mode toggle. No jailbreak or TrollStore is required for this wireless variant.

## First connection with the S24

1. Begin with the S24 and iPad on the same private Wi-Fi network, without
   client isolation. This makes the initial connection easier to diagnose.
2. On the S24, open Android Auto settings (search Settings for Android Auto).
   Enable Android Auto developer mode, then choose **Start head unit server**
   in its overflow menu. Google documents this server in its
   [head-unit testing guide](https://developer.android.com/training/cars/testing/dhu).
3. Open HeadunitPad on the iPad and allow Local Network access. Allow
   microphone access if you want voice input.
4. In HeadunitPad Settings, select **Direct Headunit Server**, **Landscape**,
   **1280x720**, **30 FPS**, and **Use Phone GPS** as the starting settings.
   Phone GPS also covers Wi-Fi-only iPads, which lack cellular GPS hardware.
5. Select **Wireless: Enter IP Manually** and enter the S24's Wi-Fi IP address
   from its connected network details. The app connects to port 5277.
6. Keep the S24 unlocked and accept any Android Auto permission/setup prompts.
7. If performance is poor, try **800x480** at **30 FPS** on the next connection.

For use away from home, test the S24's mobile hotspot with the iPad connected
to it, then enter the phone's hotspot address. Hotspot reachability varies;
if it fails, first confirm the app works on the shared Wi-Fi network.

## Device acceptance checklist

- Android Auto appears and responds to touches.
- Music plays; pause, resume, next track and volume route behave as expected.
- Maps use the S24's position and update during a route.
- Voice input records and returns to normal playback.
- Disconnect/reconnect works, including after app background/foreground.
- At least 30 minutes of operation without crash, black video or audio loss.

If connection fails, copy **Settings > Diagnostics** and record which step
failed. A successful build is not evidence that this checklist has passed.

## Project layout

`project-mini4.yml` generates an independent `HeadunitPadMini4.xcodeproj`.
`mini4/Podfile` installs OpenSSL without USBHostKit. The original Xcode
project and wired workflow remain available separately. Shared Swift source
uses `HEADUNIT_WIRELESS_ONLY` to omit USB UI and transport paths in this target.
The media controls fall back to iOS 15 APIs, while newer iPads retain their
existing now-playing session behavior.
