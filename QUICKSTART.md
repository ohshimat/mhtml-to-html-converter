# クイックスタートガイド / Quick Start Guide

## 📦 セットアップ / Setup

1. このリポジトリをダウンロードまたはクローンします
2. Windowsのコマンドプロンプトを開きます

## 🚀 3ステップで変換 / Convert in 3 Steps

### ステップ 1: ファイルを確認
MHTMLファイル（`input.mhtml`）が同じディレクトリにあることを確認します。

### ステップ 2: スクリプトを実行
```cmd
cscript convert_mhtml.vbs
```

### ステップ 3: 結果を確認
- `output.html` - 変換されたHTMLファイル
- `output_files\` - 抽出されたリソース（画像、CSS、JSなど）

## 💡 使用例 / Usage Examples

### 基本的な使用
```cmd
cscript convert_mhtml.vbs
```

### カスタムファイルを指定
```cmd
cscript convert_mhtml.vbs mypage.mhtml
```

### 出力先を指定
```cmd
cscript convert_mhtml.vbs input.mhtml C:\output
```

### バッチファイルで実行（デモ付き）
```cmd
example_usage.bat
```

## 📋 変換される内容 / What Gets Converted

| MHTML内容 | 変換後 |
|-----------|--------|
| HTML本体 | `output.html` |
| 画像（PNG, JPG, GIF等） | `output_files\*.png`, `*.jpg`等 |
| CSSスタイルシート | `output_files\*.css` |
| JavaScriptファイル | `output_files\*.js` |
| その他のリソース | `output_files\*` |

## ✅ 動作確認 / Verification

変換後、`output.html`をブラウザで開いて確認してください：

```cmd
start output.html
```

## ❓ よくある質問 / FAQ

### Q: 追加ソフトウェアは必要ですか？
A: いいえ、Windows標準機能のみで動作します。

### Q: どのWindowsバージョンで動作しますか？
A: Windows XP以降で動作します。

### Q: 既存のファイルは上書きされますか？
A: はい、`output.html`と`output_files\`は毎回新しく作成されます。

### Q: 日本語は正しく表示されますか？
A: はい、UTF-8エンコーディングで正しく処理されます。

### Q: エラーが発生したら？
A: エラーメッセージが日本語と英語で表示されます。TESTING.mdを参照してください。

## 🔧 トラブルシューティング / Troubleshooting

### スクリプトが実行されない
```cmd
cscript //nologo convert_mhtml.vbs
```

### ファイルが見つからない
入力ファイルのフルパスを指定してください：
```cmd
cscript convert_mhtml.vbs C:\path\to\file.mhtml
```

### 詳細なログが必要
スクリプト実行時の出力をファイルに保存：
```cmd
cscript convert_mhtml.vbs > log.txt 2>&1
```

## 📚 詳細情報 / More Information

- 完全なドキュメント: [README.md](README.md)
- テスト手順: [TESTING.md](TESTING.md)
- ライセンス: [LICENSE](LICENSE)

## 🎯 サンプルファイル / Sample File

`input.mhtml` にサンプルファイルが含まれています。これを使ってすぐにテストできます：

```cmd
cscript convert_mhtml.vbs
start output.html
```

---

## English Quick Start

### Convert MHTML in 3 Steps:

1. **Check** - Ensure your MHTML file is ready
2. **Run** - Execute `cscript convert_mhtml.vbs`
3. **View** - Open `output.html` in your browser

### Basic Command:
```cmd
cscript convert_mhtml.vbs [input.mhtml] [output_directory]
```

That's it! 🎉
