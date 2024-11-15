@echo off

:: 清理旧的构建文件
echo Cleaning old build...
if exist dist rmdir /s /q dist
if exist build\web rmdir /s /q build\web

:: 构建 web 项目
echo Building web project...
flutter build web --release

:: 创建 dist 目录并复制构建文件
echo Copying build files to dist...
mkdir dist
xcopy /s /e build\web\* dist\

:: 完成
echo Build completed! Output directory: .\dist 