# mhtml-to-html-converter
mhtmlからhtmlへのコンバータ

## 概要
MHTMLファイル（MIMEカプセル化されたHTMLドキュメント）を解析し、含まれる複数のHTMLパートとリソースファイル（画像、CSS、JavaScriptなど）を抽出して保存するPythonスクリプトです。

## 機能
- MHTMLファイルの解析と分割
- 各HTMLパートを個別のサブディレクトリに保存
- リソースファイル（画像、CSS、JavaScript、フォントなど）の抽出
- Base64、Quoted-Printableなどのエンコーディングに対応
- UTF-8、Shift-JIS、ISO-8859-1などの文字エンコーディングの自動検出
- ユニークなファイル名の自動生成
- エラーハンドリングと例外処理

## サポートされるリソースタイプ
- **画像**: JPEG, PNG, GIF, SVG, WebP, BMP, ICO
- **スタイルシート**: CSS
- **スクリプト**: JavaScript
- **フォント**: WOFF, WOFF2, TTF, OTF
- **その他**: JSON, XML, テキストファイルなど

## 必要な環境
- Python 3.6以上
- 標準ライブラリのみ使用（追加のインストールは不要）

## 使い方

### 基本的な使い方
```bash
python mhtml_converter.py example.mhtml
```

### 出力ディレクトリを指定
```bash
python mhtml_converter.py example.mhtml -o output_folder
```

または

```bash
python mhtml_converter.py example.mhtml --output-dir my_html_files
```

### ヘルプの表示
```bash
python mhtml_converter.py --help
```

## 出力形式
スクリプトは以下の構造でファイルを保存します：

```
output_directory/
├── html_part_1/
│   └── html_part_1_xxxxxxxx.html
├── html_part_2/
│   └── html_part_2_xxxxxxxx.html
└── resources/
    ├── resource_1_xxxxxxxx.png
    ├── resource_2_xxxxxxxx.css
    ├── resource_3_xxxxxxxx.js
    └── ...
```

各ファイルは：
- HTMLパートは個別のサブディレクトリに格納されます
- リソースファイルは `resources` ディレクトリにまとめて保存されます
- ファイル名にはSHA-256ハッシュの一部が含まれ、重複を防ぎます
- HTMLファイルはUTF-8エンコーディングで保存されます
- リソースファイルはバイナリ形式でそのまま保存されます

## サンプルファイル
リポジトリには2つのサンプルファイルが含まれています：

1. `example.mhtml` - 基本的なMHTMLファイル（HTMLのみ）
2. `example_with_resources.mhtml` - リソースファイル（CSS、画像）を含むMHTMLファイル

スクリプトの動作を確認できます：

```bash
# 基本的な例
python mhtml_converter.py example.mhtml

# リソース抽出の例
python mhtml_converter.py example_with_resources.mhtml
```

## ライセンス
このプロジェクトはオープンソースです。
