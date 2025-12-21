# mhtml-to-html-converter
mhtmlからhtmlへのコンバータ

## 概要
MHTMLファイル（MIMEカプセル化されたHTMLドキュメント）を解析し、含まれる複数のHTMLパートとリソースファイル（画像、CSS、JavaScriptなど）を抽出して保存するPythonスクリプトです。

## 機能
- MHTMLファイルの解析と分割
- 各HTMLパートを個別のサブディレクトリに保存
- リソースファイル（画像、CSS、JavaScript、フォントなど）の抽出
- **HTMLファイル内のリソースへのリンクを自動的に書き換え**
- Base64、Quoted-Printableなどのエンコーディングに対応
- UTF-8、Shift-JIS、ISO-8859-1などの文字エンコーディングの自動検出
- ユニークなファイル名の自動生成
- エラーハンドリングと例外処理

## サポートされるリソースタイプ
- **画像**: JPEG, PNG, GIF, SVG, WebP, BMP, ICO
- **スタイルシート**: CSS
- **スクリプト**: JavaScript
- **フォント**: WOFF, WOFF2, TTF, OTF
- **Microsoft Office文書**: Word (DOCX, DOC), Excel (XLSX, XLS), PowerPoint (PPTX, PPT)
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
- **HTML内のリソースへの参照（src、href属性）は自動的に相対パスに書き換えられます**
- ファイル名にはSHA-256ハッシュの一部が含まれ、重複を防ぎます
- HTMLファイルはUTF-8エンコーディングで保存されます
- リソースファイルはバイナリ形式でそのまま保存されます

## リソースリンクの保持

スクリプトは、HTMLファイル内のリソースへのリンク（`<img src="...">`、`<link href="...">` など）を自動的に検出し、抽出されたリソースファイルへの正しい相対パスに書き換えます。

**例：**
```html
<!-- 元のMHTML内 -->
<link rel="stylesheet" href="style.css">
<img src="logo.png" alt="Logo">

<!-- 変換後のHTML -->
<link rel="stylesheet" href="../resources/resource_1_3c1f8b14.css">
<img src="../resources/resource_2_6b7fa434.png" alt="Logo">
```

これにより、抽出されたHTMLファイルをブラウザで開くと、リソースが正しく読み込まれます。

## サンプルファイル
リポジトリには3つのサンプルファイルが含まれています：

1. `example.mhtml` - 基本的なMHTMLファイル（HTMLのみ）
2. `example_with_resources.mhtml` - リソースファイル（CSS、画像）を含むMHTMLファイル
3. `example_with_office_docs.mhtml` - Microsoft Office文書（DOCX、XLSX、PPTX）を含むMHTMLファイル

スクリプトの動作を確認できます：

```bash
# 基本的な例
python mhtml_converter.py example.mhtml

# リソース抽出の例
python mhtml_converter.py example_with_resources.mhtml

# Office文書の抽出例
python mhtml_converter.py example_with_office_docs.mhtml
```

## ライセンス
このプロジェクトはオープンソースです。
