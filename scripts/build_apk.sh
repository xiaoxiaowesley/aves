#!/bin/bash
set -e

# ===== 配置 =====
FLUTTER_SDK="/Users/xiaoxiang/Documents/code/software/flutter-official/bin/flutter"
FLAVOR="play"                    # play | izzy | libre
BUILD_MODE="debug"               # debug | profile | release
TARGET="lib/main_play.dart"      # 入口文件

# ===== 项目根目录（脚本所在目录的上一级）=====
cd "$(dirname "$0")/.."
PROJECT_DIR="$(pwd)"
echo "项目目录: $PROJECT_DIR"

# ===== 修复镜像源问题 =====
# 环境变量 FLUTTER_STORAGE_BASE_URL 如果指向不可用的镜像会导致构建失败
# 强制使用 Google 官方存储
export FLUTTER_STORAGE_BASE_URL="https://storage.googleapis.com"
echo "FLUTTER_STORAGE_BASE_URL=$FLUTTER_STORAGE_BASE_URL"

# ===== 检查 Flutter SDK =====
if [ ! -x "$FLUTTER_SDK" ]; then
  echo "错误: Flutter SDK 不存在: $FLUTTER_SDK"
  exit 1
fi
echo "Flutter 版本:"
"$FLUTTER_SDK" --version

# ===== 清理构建缓存 =====
echo ""
echo "===== 清理构建缓存 ====="
"$FLUTTER_SDK" clean

# ===== 应用 flavor 配置 =====
echo ""
echo "===== 应用 $FLAVOR flavor 配置 ====="
PUBSPEC="pubspec.yaml"
case "$FLAVOR" in
  play)
    sed -i '' 's|plugins/aves_services_.*|plugins/aves_services_google|g' "$PUBSPEC"
    sed -i '' 's|plugins/aves_report_.*|plugins/aves_report_crashlytics|g' "$PUBSPEC"
    TARGET="lib/main_play.dart"
    ;;
  izzy)
    sed -i '' 's|plugins/aves_services_.*|plugins/aves_services_none|g' "$PUBSPEC"
    sed -i '' 's|plugins/aves_report_.*|plugins/aves_report_console|g' "$PUBSPEC"
    TARGET="lib/main_izzy.dart"
    ;;
  libre)
    sed -i '' 's|plugins/aves_services_.*|plugins/aves_services_none|g' "$PUBSPEC"
    sed -i '' 's|plugins/aves_report_.*|plugins/aves_report_console|g' "$PUBSPEC"
    TARGET="lib/main_libre.dart"
    ;;
  *)
    echo "错误: 未知的 flavor: $FLAVOR (可选: play, izzy, libre)"
    exit 1
    ;;
esac
echo "已应用 $FLAVOR flavor 配置"

# ===== 获取依赖 =====
echo ""
echo "===== 获取依赖 ====="
"$FLUTTER_SDK" pub get

# ===== 构建 APK =====
echo ""
echo "===== 构建 $FLAVOR $BUILD_MODE APK ====="
BUILD_CMD="$FLUTTER_SDK build apk --$BUILD_MODE --flavor $FLAVOR -t $TARGET"
echo "执行: $BUILD_CMD"
$BUILD_CMD

# ===== 输出 APK 路径 =====
echo ""
echo "===== 构建完成 ====="
APK_DIR="$PROJECT_DIR/build/app/outputs/flutter-apk"
if [ -d "$APK_DIR" ]; then
  echo "APK 文件列表:"
  find "$APK_DIR" -name "*.apk" -exec ls -lh {} \;
  echo ""
  echo "你可以将 APK 安装到设备:"
  find "$APK_DIR" -name "*.apk" -exec echo "  adb install {}" \;
else
  echo "警告: 未找到 APK 输出目录: $APK_DIR"
  exit 1
fi
