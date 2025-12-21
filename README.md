# mhtml-to-html-converter
mhtmlからhtmlへのコンバータ

## 概要
MHTMLファイル（MIMEカプセル化されたHTMLドキュメント）を解析し、含まれる複数のHTMLパートを個別のファイルに分割して保存するPythonスクリプトです。

## 機能
- MHTMLファイルの解析と分割
- 各HTMLパートを個別のサブディレクトリに保存
- Base64、Quoted-Printableなどのエンコーディングに対応
- UTF-8、Shift-JIS、ISO-8859-1などの文字エンコーディングの自動検出
- ユニークなファイル名の自動生成
- エラーハンドリングと例外処理

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
スクリプトは以下の構造でHTMLファイルを保存します：

```
output_directory/
├── html_part_1/
│   └── html_part_1_xxxxxxxx.html
├── html_part_2/
│   └── html_part_2_xxxxxxxx.html
└── ...
```

各HTMLパートは：
- 個別のサブディレクトリに格納されます
- ファイル名にはMD5ハッシュの一部が含まれ、重複を防ぎます
- UTF-8エンコーディングで保存されます

## サンプルファイル
リポジトリには `example.mhtml` というサンプルファイルが含まれています。このファイルを使ってスクリプトの動作を確認できます：

```bash
python mhtml_converter.py example.mhtml
```

## ライセンス
このプロジェクトはオープンソースです。
