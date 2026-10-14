#!/usr/bin/env bash

# このスクリプトは個別のインストールコマンドをラップしてログを記録します

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${BASE_DIR}/utils/log_helper.sh"

# 引数をチェック
if [ $# -lt 2 ]; then
    echo "Usage: $0 <description> <command>"
    exit 1
fi

DESCRIPTION="$1"
shift
COMMAND="$@"

# コマンドを実行してログに記録
execute_with_log "$DESCRIPTION" "$COMMAND"