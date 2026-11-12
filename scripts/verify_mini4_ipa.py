"""Check the actual packaged app, rather than trusting build settings."""
import plistlib
import sys
from zipfile import ZipFile


def verify(path):
    with ZipFile(path) as archive:
        root = 'Payload/HeadunitPad.app/'
        names = set(archive.namelist())
        info = plistlib.loads(archive.read(root + 'Info.plist'))
        minimum = tuple(map(int, info['MinimumOSVersion'].split('.')))
        if minimum != (15, 0):
            raise ValueError(f'Unexpected minimum OS: {minimum}')
        if info.get('UIDeviceFamily') != [2]:
            raise ValueError('Package must target iPad')
        required = [info['CFBundleExecutable'], 'cert', 'privkey']
        for name in required:
            if root + name not in names:
                raise ValueError(f'Missing app resource: {name}')
        for key in ('NSLocalNetworkUsageDescription', 'NSMicrophoneUsageDescription',
                    'NSLocationWhenInUseUsageDescription', 'NSBonjourServices'):
            if not info.get(key):
                raise ValueError(f'Missing privacy declaration: {key}')
        if any('usbhostkit' in name.lower() or 'libusb' in name.lower() for name in names):
            raise ValueError('Wireless package contains a USB library')
        # Embedded frameworks can independently prevent launch on iPadOS 15.
        for name in names:
            if '.framework/' in name and name.endswith('/Info.plist'):
                framework = plistlib.loads(archive.read(name))
                version = framework.get('MinimumOSVersion', '0')
                if tuple(map(int, version.split('.'))) > (15, 0):
                    raise ValueError(f'{name} requires iOS {version}')
    print('Package verified: iPadOS 15.0, iPad, protocol resources and privacy declarations.')


if __name__ == '__main__':
    verify(sys.argv[1])
