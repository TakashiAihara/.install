# Requirements

## 概要

このリポジトリは、Ubuntu/Mac/WSL/Windows向けの開発環境初期セットアップを自動化するためのインストーラーです。dotbotを使用して、複数のOS環境で一貫した開発環境を構築します。

## 目的

- 新規環境のセットアップ時間を短縮
- 複数のOS/環境で統一された開発環境を提供
- dotfilesとシステム設定の自動管理
- 開発ツールの一括インストール

## サポート対象環境

### OS/アーキテクチャ (ARCH)
- `wsl` - Windows Subsystem for Linux (Ubuntu)
- `ubuntu` - Ubuntu Server/Desktop
- `ubuntu-dev` - Ubuntu開発環境
- `ubuntu_ct` - Ubuntu Container
- `ubuntu_nat` - Ubuntu NAT環境
- `mac` - macOS
- `windows` - Windows
- `ci` - CI環境（テスト用）

### 環境タイプ (AREA)
- `home` - ホーム環境
- `gcp` - Google Cloud Platform
- `oci` - Oracle Cloud Infrastructure
- `conoha` - ConoHa

## 主要機能

### 1. dotfiles管理
- シンボリックリンクによる設定ファイルの配置
- プライベート設定とパブリック設定の分離管理（submodule使用）
- 以下の設定を管理：
  - Shell (zsh)
  - エディタ (neovim, vim)
  - ターミナル (alacritty, tmux)
  - Git
  - SSH
  - Starship (プロンプト)
  - フォント設定

### 2. パッケージ管理
- APT パッケージインストール（Ubuntu/WSL）
- Homebrew パッケージインストール（Mac）
- PowerShell スクリプト（Windows）

### 3. 開発ツールインストール

#### バージョン管理ツール
- asdf - 複数言語のバージョン管理
- pyenv - Python バージョン管理
- sdkman - JVM言語バージョン管理

#### プログラミング言語/ランタイム
- Go
- Node.js
- Python (Poetry含む)
- Ruby
- Rust
- Scala
- Swift
- Zig
- Deno
- Bun
- Dart/Flutter

#### クラウド/インフラツール
- AWS CLI
- gcloud (Google Cloud CLI)
- Terraform / OpenTofu
- kubectl / Helm / Minikube
- Docker
- Rancher
- k3s

#### CLI ツール
- gh (GitHub CLI)
- ghq (リポジトリ管理)
- fzf (ファジーファインダー)
- ripgrep (高速grep)
- bat (catの代替)
- jq/xq (JSON/XMLパーサー)
- zoxide (cd代替)
- direnv (環境変数管理)
- httpie-go
- grpcurl

#### データベース/ミドルウェア
- PostgreSQL
- MySQL
- MongoDB
- Redis
- Memcached
- RabbitMQ
- SQLite

#### その他開発ツール
- Neovim
- Tmux
- Starship
- act (GitHub Actionsローカル実行)
- ChromeDriver
- Android SDK準備

## アーキテクチャ

### ディレクトリ構成

```
.
├── install                      # メインインストールスクリプト (Bash)
├── install.ps1                  # Windowsインストールスクリプト (PowerShell)
├── .env                         # 環境変数定義
├── install_conf/                # OS別設定定義（ソース）
│   ├── wsl.yaml
│   ├── ubuntu.yaml
│   ├── mac.yaml
│   └── windows.yaml
├── target/                      # 生成された最終設定（自動生成）
│   ├── wsl.yaml
│   ├── ubuntu.yaml
│   └── ...
├── steps/                       # 実行ステップの詳細定義
│   ├── shell/                   # シェルコマンドステップ
│   ├── link/                    # シンボリックリンクステップ
│   ├── apt/                     # APTパッケージステップ
│   ├── brewfile/                # Homebrewステップ
│   ├── defaults/                # デフォルト設定
│   ├── submodule/               # submodule管理
│   └── ps/                      # PowerShellステップ
├── links/                       # リンク対象dotfiles (submodule)
│   └── .dotfiles/
├── plugins/                     # dotbotプラグイン (submodule)
│   ├── dotbot/
│   ├── dotbot-apt/
│   └── dotbot-brewfile/
├── utils/
│   └── generate.py              # 設定ファイル生成スクリプト
└── .github/workflows/
    └── ci.yaml                  # CI/CD設定
```

### 処理フロー

1. **設定ファイル生成** (GitHub Actions / ローカル実行時)
   - `utils/generate.py` が `install_conf/*.yaml` を読み込み
   - カスタムYAMLタグ（`!shell`, `!link`, `!apt`など）を展開
   - `steps/` 内の対応するファイルを読み込み、マージ
   - 最終的な設定を `target/*.yaml` に出力

2. **インストール実行**
   - `./install` スクリプトを実行（環境変数 AREA, ARCH を指定）
   - dotbotが `target/_prepare.yaml` を実行（準備処理）
   - dotbotが `target/${ARCH}.yaml` を実行（メイン処理）
   - 各ステップを順次実行：
     - defaults: デフォルト設定
     - submodule: Gitサブモジュール更新
     - clean: クリーンアップ
     - create: ディレクトリ作成
     - link: シンボリックリンク作成
     - shell: シェルコマンド実行
     - apt/brewfile: パッケージインストール

3. **GitHub Actions CI**
   - プッシュ時に自動実行
   - `generate.py` で設定ファイル生成
   - 生成結果を自動コミット
   - CI環境でインストールテスト実行

### カスタムYAMLタグ

設定ファイル（`install_conf/*.yaml`）では、以下のカスタムタグを使用：

- `!defaults <name>`: デフォルト設定の読み込み
- `!submodule <names>`: サブモジュールステップの展開
- `!link <names>`: リンクステップの展開
- `!shell <names>`: シェルコマンドステップの展開
- `!apt <name>`: APTパッケージステップの展開
- `!brewfile <name>`: Homebrewステップの展開
- `!ps <names>`: PowerShellステップの展開

## 使用方法

### 前提条件

#### WSL/Ubuntu
```bash
apt update
apt install -y gh python3
update-alternatives --install /usr/bin/python python /usr/bin/python3 1
gh auth login
```

### インストール実行

```bash
# WSL (ホーム環境)
AREA=home ARCH=wsl ./install

# Ubuntu Server (GCP環境)
AREA=gcp ARCH=ubuntu ./install

# macOS (ホーム環境)
AREA=home ARCH=mac ./install

# Windows (要管理者権限)
$Env:AREA="home" ; $Env:ARCH="windows" ; .\install.ps1
```

### 開発時のワークフロー

1. `install_conf/*.yaml` を編集
2. `python utils/generate.py` で設定生成（または git push でCI実行）
3. `./install` でローカルテスト
4. コミット＆プッシュ

## 技術スタック

- **dotbot**: 設定ファイル配置・シンボリックリンク管理
- **Python**: 設定ファイル生成スクリプト
- **Bash/PowerShell**: インストールスクリプト
- **GitHub Actions**: CI/CD
- **Git Submodules**: dotfilesとプラグインの管理
- **YAML**: 設定ファイル形式

## 拡張性

新しいツールやステップを追加する場合：

1. `steps/<category>/` に新しいYAMLファイルを追加
2. `install_conf/<arch>.yaml` でそのステップを参照
3. GitHub ActionsまたはローカルでYAML生成
4. テスト実行

## セキュリティ

- プライベート設定は別submoduleで管理（`.dotfiles`、`etc`、`.ssh`）
- GitHub認証は `gh auth login` で事前実施
- SSH鍵は手動配置または既存submoduleから取得
