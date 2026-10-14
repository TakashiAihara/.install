#!/usr/bin/env bash

# ログファイルの設定
LOG_FILE="${LOG_FILE:-$HOME/.install.log}"
LOG_DIR="$(dirname "$LOG_FILE")"

# ログディレクトリが存在しない場合は作成
[ ! -d "$LOG_DIR" ] && mkdir -p "$LOG_DIR"

# タイムスタンプを付けてログを記録する関数
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# コマンドを実行してログに記録する関数
execute_with_log() {
    local description="$1"
    shift
    local command="$@"
    
    # 開始ログ
    log_message "INFO" "Starting: $description"
    log_message "DEBUG" "Command: $command"
    
    # 一時ファイルの作成
    local tmp_stdout=$(mktemp)
    local tmp_stderr=$(mktemp)
    
    # コマンドの実行
    local start_time=$(date +%s)
    eval "$command" > "$tmp_stdout" 2> "$tmp_stderr"
    local exit_code=$?
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # 結果のログ記録
    if [ $exit_code -eq 0 ]; then
        log_message "SUCCESS" "$description completed successfully (duration: ${duration}s)"
    else
        log_message "ERROR" "$description failed with exit code $exit_code (duration: ${duration}s)"
    fi
    
    # 標準出力のログ記録
    if [ -s "$tmp_stdout" ]; then
        log_message "STDOUT" "$description output:"
        cat "$tmp_stdout" | while IFS= read -r line; do
            echo "  $line" >> "$LOG_FILE"
        done
    fi
    
    # 標準エラーのログ記録
    if [ -s "$tmp_stderr" ]; then
        log_message "STDERR" "$description error output:"
        cat "$tmp_stderr" | while IFS= read -r line; do
            echo "  $line" >> "$LOG_FILE"
        done
    fi
    
    # 標準出力とエラーを画面に表示
    cat "$tmp_stdout"
    cat "$tmp_stderr" >&2
    
    # 一時ファイルの削除
    rm -f "$tmp_stdout" "$tmp_stderr"
    
    return $exit_code
}

# インストール状態をチェックする関数
check_installation() {
    local name="$1"
    local check_command="$2"
    
    log_message "CHECK" "Checking installation status for: $name"
    
    if eval "$check_command" &>/dev/null; then
        log_message "CHECK" "$name is already installed"
        return 0
    else
        log_message "CHECK" "$name is not installed"
        return 1
    fi
}

# サマリーを生成する関数
generate_summary() {
    local log_file="${1:-$LOG_FILE}"
    
    echo "=== Installation Summary ==="
    echo "Log file: $log_file"
    echo ""
    
    # 成功したインストール
    echo "Successfully installed:"
    grep "\[SUCCESS\]" "$log_file" | sed 's/.*\[SUCCESS\] /  - /' | sort -u
    
    echo ""
    
    # 失敗したインストール
    echo "Failed installations:"
    grep "\[ERROR\]" "$log_file" | sed 's/.*\[ERROR\] /  - /' | sort -u
    
    echo ""
    
    # 統計
    local total_success=$(grep -c "\[SUCCESS\]" "$log_file" || echo 0)
    local total_error=$(grep -c "\[ERROR\]" "$log_file" || echo 0)
    local total=$((total_success + total_error))
    
    echo "Statistics:"
    echo "  Total operations: $total"
    echo "  Successful: $total_success"
    echo "  Failed: $total_error"
    
    if [ $total_error -gt 0 ]; then
        echo ""
        echo "Please check the log file for error details."
    fi
}