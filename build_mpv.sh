#!/usr/bin/env bash

# Builds mpv & mpv.app on Apple silicon Macs with libarchive support.
# Run this script from the root directory of the mpv repo.

# if anything fails, gtfo
set -ex

# Make sure pkg-config is installed
if ! command -v pkg-config &>/dev/null; then
    echo "Installing pkg-config..."
    brew install pkg-config
fi

# Check if libarchive is installed, install if not
if ! brew list libarchive &>/dev/null; then
    echo "Installing libarchive dependency..."
    brew install libarchive
fi

# Get libarchive location from Homebrew
LIBARCHIVE_PREFIX=$(brew --prefix libarchive)
echo "libarchive is installed at: $LIBARCHIVE_PREFIX"

# Setup environment variables so pkg-config can find libarchive
export PKG_CONFIG_PATH="$LIBARCHIVE_PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"
export LDFLAGS="-L$LIBARCHIVE_PREFIX/lib $LDFLAGS"
export CPPFLAGS="-I$LIBARCHIVE_PREFIX/include $CPPFLAGS"

# Verify pkg-config can find libarchive
if pkg-config --exists libarchive; then
    echo "pkg-config found libarchive:"
    pkg-config --modversion libarchive
    echo "libarchive CFLAGS: $(pkg-config --cflags libarchive)"
    echo "libarchive LIBS: $(pkg-config --libs libarchive)"
else
    echo "ERROR: pkg-config cannot find libarchive"
    echo "Available pkgconfig files in $LIBARCHIVE_PREFIX/lib/pkgconfig:"
    ls -la $LIBARCHIVE_PREFIX/lib/pkgconfig
    exit 1
fi

# Clean previous build if it exists
rm -rf build

# Configure with libarchive support and explicitly specify the path
meson setup build \
    -Dlibarchive=enabled \
    -Dpkg_config_path="$LIBARCHIVE_PREFIX/lib/pkgconfig"

meson compile -C build

# test the binary we just built
./build/mpv --version

./TOOLS/osxbundle.py --skip-deps build/mpv
if [[ $1 == "--static" ]]; then
    dylibbundler --bundle-deps --dest-dir build/mpv.app/Contents/MacOS/lib/ --install-path @executable_path/lib/ --fix-file build/mpv.app/Contents/MacOS/mpv
    # test the app bundle binary to make sure all the dylibs made it okay
    ./build/mpv.app/Contents/MacOS/mpv --version
fi
