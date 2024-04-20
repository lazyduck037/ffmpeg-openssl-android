#!/usr/bin/env bash

function find_host_tag() {
    case "$OSTYPE" in
    darwin*)  export HOST_TAG="darwin-x86_64" ;;
    linux*)   export HOST_TAG="linux-x86_64" ;;
    msys)
        case "$(uname -m)" in
        x86_64) export HOST_TAG="windows-x86_64" ;;
        i686)   export HOST_TAG="windows" ;;
        esac
    ;;
    esac
}

function find_compiler() {
    export TARGET_TRIPLE_OS="android"
    ANDROID_ABI_PARAM=$1
    TARGET_TRIPLE_MACHINE_CC=
    case $ANDROID_ABI_PARAM in
    armeabi-v7a)
        export TARGET_TRIPLE_MACHINE_ARCH=arm
        TARGET_TRIPLE_MACHINE_CC=armv7a
        export TARGET_TRIPLE_OS=androideabi
        ;;
    arm64-v8a)
        export TARGET_TRIPLE_MACHINE_ARCH=aarch64
        ;;
    x86)
        export TARGET_TRIPLE_MACHINE_ARCH=i686
        ;;
    x86_64)
        export TARGET_TRIPLE_MACHINE_ARCH=x86_64
        ;;
    esac
    if [ -z "${TARGET_TRIPLE_MACHINE_CC}" ]; then
        TARGET_TRIPLE_MACHINE_CC=${TARGET_TRIPLE_MACHINE_ARCH}
    fi
    export TARGET_TRIPLE_MACHINE_CC=${TARGET_TRIPLE_MACHINE_CC}
    export TARGET=${TARGET_TRIPLE_MACHINE_CC}-linux-${TARGET_TRIPLE_OS}${ANDROID_PLATFORM}
    export TOOLCHAIN_PATH=${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/${HOST_TAG}
    export NDK_CC=${TOOLCHAIN_PATH}/bin/${TARGET}-clang
    export MAKE_EXE=${ANDROID_NDK_HOME}/prebuilt/${HOST_TAG}/bin/make
    export SYSROOT_PATH=${TOOLCHAIN_PATH}/sysroot
    export CROSS_PREFIX_WITH_PATH=${TOOLCHAIN_PATH}/bin/llvm-

    export INSTALL_DIR=${EXTERNAL_DIR}/${ANDROID_ABI_PARAM}

    export NDK_CXX=${NDK_CC}++
    export NDK_LD=${NDK_CC}
    export NDK_AR=${CROSS_PREFIX_WITH_PATH}ar
    export NDK_AS=${CROSS_PREFIX_WITH_PATH}as
    export NDK_NM=${CROSS_PREFIX_WITH_PATH}nm
    export NDK_RANLIB=${CROSS_PREFIX_WITH_PATH}ranlib
    export NDK_STRIP=${CROSS_PREFIX_WITH_PATH}strip
    export PKG_CONFIG_DIR=${INSTALL_DIR}/lib/pkgconfig
    export PKG_CONFIG_PATH=${INSTALL_DIR}/lib/pkgconfig
    export PKG_CONFIG_LIBDIR=${INSTALL_DIR}/lib/pkgconfig
}

function fetch_openssl() {
    LIB_NAME=$1
    if [ ! -d ${LIB_NAME} ]; then
        echo "Downloading ${LIB_NAME}"
        wget https://github.com/openssl/openssl/archive/refs/tags/openssl-3.3.0.tar.gz
        tar -xf openssl-3.3.0.tar.gz
        mv openssl-openssl-3.3.0 $LIB_NAME
        rm openssl-3.3.0.tar.gz
    else
        echo "Using existing `pwd`/${LIB_NAME}"
    fi
}

function build_openssl() {
    ANDROID_ABI_PARAM=$1
    CC=${NDK_CC}
    RANLIB=${NDK_RANLIB}
    AR=${NDK_AR}
    PATH=${TOOLCHAIN_PATH}/bin:${TOOLCHAIN_PATH}/bin:/usr/bin:/bin
    export ANDROID_NDK_ROOT=${ANDROID_NDK_HOME}
    TARGET_OPENSSL_ARM=
    case $ANDROID_ABI_PARAM in
    armeabi-v7a)
        TARGET_OPENSSL_ARM=android-arm
        ;;
    arm64-v8a)
        TARGET_OPENSSL_ARM=android-arm64
        ;;
    x86)
        TARGET_OPENSSL_ARM=android-x86
        ;;
    x86_64)
        TARGET_OPENSSL_ARM=android-x86_64
        ;;
    esac
    ./Configure $TARGET_OPENSSL_ARM no-shared -D__ANDROID_API__=${ANDROID_PLATFORM} -I${SYSROOT_PATH}/usr/include --prefix=${INSTALL_DIR}
    ${MAKE_EXE} clean
    ${MAKE_EXE} depend
    ${MAKE_EXE} build_libs
    ${MAKE_EXE} install_sw
}

function fetch_ffmpeg() {
    LIB_NAME=$1
    if [ ! -d ${LIB_NAME} ]; then
        echo "Downloading ${LIB_NAME}"
        curl -O https://ffmpeg.org/releases/ffmpeg-7.0.tar.xz
        tar -xf ffmpeg-7.0.tar.xz
        mv ffmpeg-7.0 $LIB_NAME
        rm ffmpeg-7.0.tar.xz
    else
        echo "Using existing `pwd`/${LIB_NAME}"
    fi
}

function build_ffmpeg() {
    ANDROID_ABI_PARAM=$1
    EXTRA_BUILD_CONFIGURATION_FLAGS=
    case $ANDROID_ABI_PARAM in
    x86)
        # Disabling assembler optimizations, because they have text relocations
        EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS --disable-asm"
        ;;
    x86_64)
        EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS --x86asmexe=${NDK_YASM}"
        ;;
    esac

    if [ "$FFMPEG_GPL_ENABLED" = true ] ; then
        EXTRA_BUILD_CONFIGURATION_FLAGS="$EXTRA_BUILD_CONFIGURATION_FLAGS --enable-gpl"
    fi

    DEP_CFLAGS="-I${EXTERNAL_DIR}/${ANDROID_ABI_PARAM}/include"
    DEP_LD_FLAGS="-L${EXTERNAL_DIR}/${ANDROID_ABI_PARAM}/lib $FFMPEG_EXTRA_LD_FLAGS"

    export BUILD_DIR_FFMPEG=$BUILD_DIR/ffmpeg
    ./configure \
        --prefix=${BUILD_DIR_FFMPEG}/${ANDROID_ABI_PARAM} \
        --enable-cross-compile \
        --target-os=android \
        --arch=${TARGET_TRIPLE_MACHINE_ARCH} \
        --sysroot=${SYSROOT_PATH} \
        --cc=${NDK_CC} \
        --cxx=${NDK_CXX} \
        --ld=${NDK_LD} \
        --ar=${NDK_AR} \
        --as=${NDK_CC} \
        --nm=${NDK_NM} \
        --ranlib=${NDK_RANLIB} \
        --strip=${NDK_STRIP} \
        --extra-cflags="-O3 -fPIC $DEP_CFLAGS" \
        --extra-ldflags="$DEP_LD_FLAGS" \
        --enable-shared \
        --enable-openssl \
        --enable-version3 \
        --disable-static \
        --disable-vulkan \
        --pkg-config=${PKG_CONFIG_EXE} \
        ${EXTRA_BUILD_CONFIGURATION_FLAGS} || exit 1

    ${MAKE_EXE} clean
    ${MAKE_EXE}
    ${MAKE_EXE} install

}
