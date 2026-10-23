#!/usr/bin/env bash
set -e

# System deps
sudo apt-get update
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Flutter SDK (stable)
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$HOME/flutter"
fi
export PATH="$PATH:$HOME/flutter/bin"

# Android SDK (for building APKs)
export ANDROID_HOME="$HOME/android-sdk"
mkdir -p "$ANDROID_HOME/cmdline-tools"
if [ ! -d "$ANDROID_HOME/cmdline-tools/latest" ]; then
  curl -o /tmp/cmdtools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
  unzip -q /tmp/cmdtools.zip -d /tmp/cmdtools
  mv /tmp/cmdtools/cmdline-tools "$ANDROID_HOME/cmdline-tools/latest"
  rm -rf /tmp/cmdtools.zip /tmp/cmdtools
fi
yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses >/dev/null || true
"$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" \
  "platform-tools" "platforms;android-35" "build-tools;35.0.0"

# Flutter config
flutter config --no-analytics
flutter config --android-sdk "$ANDROID_HOME"
flutter config --enable-web
flutter precache --web --android
yes | flutter doctor --android-licenses >/dev/null || true

# Convenience aliases
cat >> ~/.bashrc <<'EOF'
alias fweb='flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080'
alias fapk='flutter build apk --debug'
alias fapkr='flutter build apk --release'
EOF

flutter doctor

