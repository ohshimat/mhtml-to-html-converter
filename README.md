# mhtml-to-html-converter
mhtmlからhtmlへのコンバータ

## 概要 (Overview)

MHTML (MIME HTML) ファイルを独立したHTMLファイルに変換するPythonスクリプトです。
画像、CSS、JavaScriptなどの埋め込みリソースをdata URIとして変換し、単一のHTMLファイルとして出力します。

A Python script that converts MHTML (MIME HTML) files to standalone HTML files.
It converts embedded resources like images, CSS, and JavaScript to data URIs and outputs a single HTML file.

## 必要条件 (Requirements)

- Python 3.6以上 (Python 3.6+)
- 標準ライブラリのみ使用 (Uses only standard library modules)

## 使い方 (Usage)

### 基本的な使い方 (Basic Usage)

```bash
python3 mhtml_converter.py <input.mhtml> [output.html]
```

### 例 (Examples)

```bash
# MHTMLファイルをHTMLに変換（出力ファイル名は自動生成）
# Convert MHTML to HTML (output filename is auto-generated)
python3 mhtml_converter.py test_example.mhtml

# 出力ファイル名を指定
# Specify output filename
python3 mhtml_converter.py test_example.mhtml output.html
```

## 機能 (Features)

- ✅ MHTMLファイルのパース (Parse MHTML files)
- ✅ 埋め込みリソースの抽出 (Extract embedded resources)
- ✅ 画像、CSS、JavaScriptなどをdata URIに変換 (Convert images, CSS, JavaScript to data URIs)
- ✅ スタンドアロンHTMLファイルの生成 (Generate standalone HTML files)
- ✅ Base64およびQuoted-Printableエンコーディングのサポート (Support for Base64 and Quoted-Printable encodings)

## テスト (Testing)

サンプルのMHTMLファイルが含まれています：
A sample MHTML file is included:

```bash
python3 mhtml_converter.py test_example.mhtml
```

## ライセンス (License)

MIT License
