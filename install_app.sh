#!/bin/bash

set -e

# 获取1Panel安装目录
BASE_DIR=$(which 1pctl | xargs grep '^BASE_DIR=' | cut -d'=' -f2)
[ -z "$BASE_DIR" ] && { echo "Error: 1Panel directory not found."; exit 1; }

# 定义路径
APP_STORE_DIR="$BASE_DIR/1panel/resource/apps/local/appstore-localApps"
LOCAL_DIR="$BASE_DIR/1panel/resource/apps/local"
DEST_ENVS_DIR="/etc/1panel/envs"

echo "$(date): Starting 1Panel appstore installation from talentestors/appstore-1panel (main)"

# 克隆仓库
rm -rf "$APP_STORE_DIR"
git clone --depth 1 -b main https://github.com/talentestors/appstore-1panel "$APP_STORE_DIR" || exit 1

# 复制应用
for app_dir in "$APP_STORE_DIR/apps"/*; do
    [ -d "$app_dir" ] || continue
    app_name=$(basename "$app_dir")
    rm -rf "$LOCAL_DIR/$app_name"
    cp -r "$app_dir" "$LOCAL_DIR/"
    echo "$(date): Installed $app_name"
done

# 复制环境变量文件
if [ -d "$APP_STORE_DIR/envs" ]; then
    mkdir -p "$DEST_ENVS_DIR"
    rm -rf "$DEST_ENVS_DIR"/*
    cp -r "$APP_STORE_DIR/envs"/* "$DEST_ENVS_DIR/"
    echo "$(date): Copied envs to $DEST_ENVS_DIR"
fi

# 清理临时目录
rm -rf "$APP_STORE_DIR"

echo "$(date): Installation completed successfully!"
