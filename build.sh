#!/usr/bin/env bash
source libs.sh

if [ "$ANDROID_SDK_HOME" = "" ] || [ ! -d $ANDROID_SDK_HOME ]; then
	echo "ANDROID_SDK_HOME variable not set or path to ANDROID_SDK_HOME is invalid, exiting..."
	exit 1
fi

if [ "$ANDROID_NDK_HOME" = "" ] || [ ! -d $ANDROID_NDK_HOME ]; then
	echo "ANDROID_NDK_HOME variable not set or path to ANDROID_NDK_HOME is invalid, exiting..."
	exit 1
fi
ADROID_ALL_ABIS=("x86" "x86_64" "armeabi-v7a" "arm64-v8a")
export ANDROID_PLATFORM=21
export CURRENT_DIR="$(pwd)"
export BUILD_DIR=${CURRENT_DIR}/build
export EXTERNAL_DIR=$BUILD_DIR/external
export PKG_CONFIG_EXE=$(which pkg-config)

find_host_tag

# openssl
fetch_openssl openssl
pushd ${CURRENT_DIR}/openssl
for ABI in ${ADROID_ALL_ABIS[@]}
do
  find_compiler $ABI
  build_openssl $ABI
done
popd

# ffmpeg
fetch_ffmpeg ffmpeg 
pushd ${CURRENT_DIR}/ffmpeg
for ABI in ${ADROID_ALL_ABIS[@]}
do
  find_compiler $ABI
  build_ffmpeg $ABI
done
popd