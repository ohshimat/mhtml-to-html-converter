# MHTML to HTML Converter

MHTMLファイルをHTMLファイルとそのリソース（画像、CSS、JavaScriptなど）に分解するWindowsツール

## 概要

このツールは、VBScriptを使用してMHTML（MIME HTML）ファイルを通常のHTMLファイルと関連リソースに変換します。Windows標準の機能のみを使用しており、追加のライブラリやソフトウェアは不要です。

## 機能

- ✅ MHTMLファイルの解析とMIMEパートの分離
- ✅ HTMLコンテンツの抽出と保存
- ✅ リソース（画像、CSS、JavaScript等）の抽出と保存
- ✅ Base64およびQuoted-Printableエンコーディングのデコード
- ✅ HTMLファイル内の参照の自動更新
- ✅ 重複ファイル名の自動処理
- ✅ エラーハンドリングと進捗表示
- ✅ 日本語対応

## 使用方法

### 基本的な使い方

```cmd
cscript convert_mhtml.vbs
```

デフォルトでは、カレントディレクトリの `input.mhtml` を読み込み、以下のファイルを生成します：
- `output.html` - HTMLファイル
- `output_files/` - リソースディレクトリ

### カスタムファイルを指定

```cmd
cscript convert_mhtml.vbs myfile.mhtml
```

### 出力ディレクトリを指定

```cmd
cscript convert_mhtml.vbs input.mhtml C:\output
```

## 出力構造

変換後のファイル構造：

```
output.html
output_files/
    ├── style.css
    ├── script.js
    ├── image001.png
    └── ...
```

## 動作要件

- **OS**: Windows 7以降（推奨: Windows 10/11）
- **必要なコンポーネント**: 
  - Windows Script Host (cscript.exe)
  - FileSystemObject (標準)
  - MSXML2.DOMDocument (標準)
  - ADODB.Stream (標準)

## テスト方法

サンプルMHTMLファイル（`input.mhtml`）が同梱されています。

```cmd
cscript convert_mhtml.vbs
```

実行後、生成された `output.html` をブラウザで開いて確認してください。

## エラーハンドリング

ツールは以下のエラーを適切に処理します：

- ファイルが存在しない場合
- MHTMLフォーマットが不正な場合
- ディスク容量不足の場合
- アクセス権限の問題

エラーメッセージは日本語と英語の両方で表示されます。

## 実装の特徴

### MHTMLパーサー
- MIMEマルチパート構造の完全解析
- 各パートのヘッダーとボディの分離
- Content-Type、Content-Location、Content-Transfer-Encodingの抽出

### エンコーディング対応
- Base64デコード（バイナリファイル用）
- Quoted-Printableデコード（テキストファイル用）
- UTF-8サポート

### 参照の更新
- `file:///` 形式のURLを相対パスに変換
- `cid:` 形式の参照を相対パスに変換
- リソースへのリンクを自動的に更新

### ファイル名の処理
- URLエンコーディングのデコード
- 重複ファイル名の自動リネーム（例: `image.png` → `image_1.png`）
- クエリ文字列の除去

## ライセンス

MITライセンス

## トラブルシューティング

### スクリプトが実行されない場合

```cmd
cscript //nologo convert_mhtml.vbs
```

### 詳細なエラー情報が必要な場合

スクリプトはエラーコードと説明を表示します。問題が解決しない場合は、MHTMLファイルの形式を確認してください。

## サンプルMHTMLファイル

`input.mhtml` には以下が含まれています：
- HTMLページ（日本語タイトル付き）
- CSSスタイルシート
- JavaScriptファイル
- PNGイメージ（Base64エンコード）

## 貢献

プルリクエストを歓迎します。大きな変更の場合は、まずIssueを開いて変更内容を議論してください。

---

## MHTML to HTML Converter (English)

A Windows tool to convert MHTML files to HTML files with extracted resources (images, CSS, JavaScript, etc.)

### Quick Start

```cmd
cscript convert_mhtml.vbs [input.mhtml] [output_directory]
```

### Requirements

- Windows 7 or later (Recommended: Windows 10/11)
- Windows Script Host (included in Windows)

### Features

- Parse MHTML MIME multipart structure
- Extract HTML content
- Extract and save resources (images, CSS, JS)
- Decode Base64 and Quoted-Printable encodings
- Update HTML references automatically
- Handle duplicate filenames
- Error handling and progress messages
- Japanese language support
