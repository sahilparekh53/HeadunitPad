# Permanent installation on this iPad

Target: iPad mini 4 (A8), iPadOS 15.8.5. The user requests permanent installation; no device-level changes have been performed.

Ordinary AltStore free signing expires and requires refresh. This is an installation/signing property, not something a reconnect or UI change can remove.

## Supported route to review

[TrollStore](https://github.com/opa334/TrollStore) can install compatible IPAs without periodic developer resigning on supported systems. The current [device/version guide](https://ios.cfw.guide/installing-trollstore/) includes A8 iPads on 15.8.5.

The documented Windows [TrollRestore procedure](https://ios.cfw.guide/installing-trollstore-trollrestore/) requires:

1. A current iPad backup and the working HeadunitPad IPA retained as a fallback.
2. The user temporarily disables Find My on the iPad.
3. TrollRestore restores a modified backup and replaces a selected system app, typically Tips, with the installer helper. This reboots the iPad.
4. The user opens that helper, installs TrollStore, and sets up its persistence helper.
5. Import the verified HeadunitPad IPA into TrollStore, then verify app launch, a reboot, and the S24 connection. Handle migration from the existing AltStore copy explicitly so saved data is not discarded accidentally.
6. Re-enable Find My after completing the procedure.

This changes device installation behavior and a system app. The user must approve this concrete route and perform security/account prompts themselves before any modified-backup restore or system-app replacement. This document is preparation, not evidence that TrollStore has been installed.

The alternative [TrollMisaka route](https://ios.cfw.guide/installing-trollstore-trollmisaka/) covers this A8/iPadOS range, but its guide describes it as extremely unreliable. It requires keyboard/full-access setup and is not treated here as a seamless or automatic solution.

Do not promise that installation will survive an unsupported iPadOS update or a device erase. No unofficial signing certificate or paid signing service is required by the TrollStore route itself.

## App package

The wireless HeadunitPad IPA is unsigned for installation and requests no private USB entitlements. The ordinary build can be signed by AltStore or imported into a compatible TrollStore installation. No private entitlements are being added merely to style the app or avoid signing expiry.

USB access, if separately proved on the mini 4, would need a separately reviewed build and USB entitlements. Permanent installation alone does not prove Lightning USB-host access or Wi-Fi Direct support.
