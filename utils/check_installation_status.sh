#!/usr/bin/env bash

# インストール状態を確認するスクリプト

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${BASE_DIR}/utils/log_helper.sh"

echo "=== Installation Status Check ==="
echo "Checking common tools installation status..."
echo ""

installed_count=0
not_installed_count=0

# ツールをチェックする関数
check_tool() {
    local name="$1"
    local command="$2"
    local display_name="${name//_/ }"
    
    printf "%-20s: " "$display_name"
    if eval "$command" &>/dev/null; then
        echo "✓ Installed"
        ((installed_count++))
    else
        echo "✗ Not installed"
        ((not_installed_count++))
    fi
}

# 各ツールをチェック
check_tool "Docker" "docker --version"
check_tool "Docker_Compose" "docker compose version"
check_tool "Git" "git --version"
check_tool "GitHub_CLI" "gh --version"
check_tool "Node.js" "node --version"
check_tool "npm" "npm --version"
check_tool "Python" "python3 --version"
check_tool "Go" "go version"
check_tool "Rust" "rustc --version"
check_tool "Ruby" "ruby --version"
check_tool "Java" "java --version 2>&1"
check_tool "fzf" "fzf --version"
check_tool "zoxide" "zoxide --version"
check_tool "starship" "starship --version"
check_tool "Poetry" "poetry --version"
check_tool "pyenv" "pyenv --version"
check_tool "rbenv" "rbenv --version"
check_tool "gcloud" "gcloud --version 2>&1 | head -1"
check_tool "act" "act --version"
check_tool "ghq" "ghq --version"

echo ""
echo "Summary:"
echo "  Installed: $installed_count"
echo "  Not installed: $not_installed_count"
echo ""

# 最新のログファイルの情報を表示
if [ -f "$LOG_FILE" ]; then
    echo "Latest log entries:"
    echo "-------------------"
    tail -20 "$LOG_FILE" | grep -E "\[(SUCCESS|ERROR|WARNING)\]"
    echo ""
    echo "Full log file: $LOG_FILE"
else
    echo "No log file found at: $LOG_FILE"
fi

# メンテナンスが必要な項目を確認
echo ""
echo "=== Maintenance Check ==="

# 失敗したインストールがある場合
if [ -f "$LOG_FILE" ] && grep -q "\[ERROR\]" "$LOG_FILE"; then
    echo "⚠️  Failed installations detected:"
    grep "\[ERROR\]" "$LOG_FILE" | tail -10 | sed 's/.*\[ERROR\] /  - /'
    echo ""
fi

# アップデートが必要なツールをチェック（例）
echo "Checking for available updates..."

# Homebrew (macOS)
if command -v brew &>/dev/null; then
    outdated=$(brew outdated 2>/dev/null | wc -l | tr -d ' ')
    if [ "$outdated" -gt 0 ]; then
        echo "  - Homebrew: $outdated packages can be updated"
    fi
fi

# apt (Ubuntu/WSL)
if command -v apt &>/dev/null; then
    if sudo -n apt update &>/dev/null 2>&1; then
        upgradable=$(apt list --upgradable 2>/dev/null | grep -c "upgradable" || echo 0)
        if [ "$upgradable" -gt 0 ]; then
            echo "  - APT: $upgradable packages can be upgraded"
        fi
    fi
fi

echo ""
echo "Run this script periodically to check installation status and maintenance needs."