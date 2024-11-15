#!/bin/bash

# 错误时退出
set -e

# 清理旧的构建文件
echo "Cleaning old build..."
rm -rf dist
rm -rf build/web

# 构建 web 项目
echo "Building web project..."
flutter build web --release

# 创建 dist 目录并复制构建文件
echo "Copying build files to dist..."
mkdir -p dist
cp -r build/web/* dist/

# 完成
echo "Build completed! Output directory: ./dist" 