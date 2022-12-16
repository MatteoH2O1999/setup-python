import sys

def check_version(version):
    split_version = version.split('.')
    if int(split_version[0]) != sys.version_info.major:
        return False
    if split_version[1] != 'x' and int(split_version[1]) != sys.version_info.minor:
        return False
    if split_version[2] != 'x' and int(split_version[2]) != sys.version_info.micro:
        return False
    return True

if __name__ == '__main__':
    version = sys.argv[1]
    while version.count('.') < 2:
        version += '.x'
    if not check_version(version):
        raise ValueError('Expected python version to be ' + str(version) + ', got ' + str(sys.version_info.major) + '.' + str(sys.version_info.minor) + '.' + str(sys.version_info.micro) + '.')