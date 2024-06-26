# Prebuild ffmpeg, openssl for Android platform
This repo contains build scripts to build FFmeg-7.0, Openssl-3.3.0 libs and executable binary for Android. It also builds FFmeg with dependences Openssl in the repo.
# Supported Android ABIs
+ `armeabi` (Android 21+)
+ `armeabi-v7a` (Android 21+)
+ `x86`  (Android 21+)
+ `arm64-v8a`  (Android 21+)
+ `x86_64` (Android 21+)
# Source Version 
 * **FFmeg 7.0** [Download](https://ffmpeg.org/releases/ffmpeg-7.0.tar.xz)
 * **OpenSSL 3.3.0** [Download](https://github.com/openssl/openssl/archive/refs/tags/openssl-3.3.0.tar.gz)
 ## Build
 Build with:
  * Android NDK: [r25c(25.2.9519653)](https://github.com/android/ndk/wiki/Unsupported-Downloads)
  * HOST: MAC/OSX, Linux (Not Test)

 My computer: MAC/OSX 14.4.1 (23E224) Apple M1

Run to build:
```bash
export ANDROID_NDK_HOME=path/to/android-ndk
export ANDROID_SDK_HOME=path/to/android-sdk
./build.sh
```
My case:
```bash
export ANDROID_NDK_HOME=/Users/lap15292-local/Android/Sdk/ndk/25.1.8937393 && \
export ANDROID_SDK_HOME=/Users/lap15292-local/Android/Sdk && \
./build.sh
```
## Download

## References
  - [FfmpegOpensslX264BinaryAndroid](https://github.com/lazyduck037/ffmpeg-openssl-x264-binary-android) by [lazyduck037](https://github.com/lazyduck037)

## FFmpeg license
This software uses code of <a href="http://ffmpeg.org">FFmpeg</a> licensed under the <a href="http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html">LGPLv2.1</a> and its source can be downloaded [here](https://ffmpeg.org/releases/ffmpeg-7.0.tar.xz).
