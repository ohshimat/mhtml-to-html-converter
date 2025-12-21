# テスト手順 / Testing Guide

## MHTML to HTML Converter のテスト

このドキュメントでは、MHTML to HTML Converterのテスト方法を説明します。

## 前提条件 / Prerequisites

- Windows OS (XP以降 / XP or later)
- Windows Script Host (標準でインストール済み / Pre-installed)

## テスト方法 / Testing Instructions

### 1. 基本的な変換テスト / Basic Conversion Test

コマンドプロンプトを開き、以下のコマンドを実行します：

```cmd
cd path\to\mhtml-to-html-converter
cscript convert_mhtml.vbs
```

#### 期待される結果 / Expected Results:

1. 以下のメッセージが表示される：
   ```
   ============================================
   MHTML to HTML Converter
   ============================================
   
   入力ファイル: [フルパス]\input.mhtml
   出力ディレクトリ: [フルパス]
   
   リソースディレクトリを作成: [フルパス]\output_files
   
   MHTMLファイルを解析中...
   バウンダリ: ----=_NextPart_000_0000_01D9A1B2.C3D4E5F6
   MIMEパート数: 4
   
   HTMLコンテンツを抽出 (XXX バイト)
     リソース保存 (Quoted-Printable): style.css
     リソース保存 (Quoted-Printable): script.js
     リソース保存 (Base64): image001.png
   
   HTMLファイルの参照を更新中...
   HTMLファイルを保存: [フルパス]\output.html
   
   保存されたリソース: 3 ファイル
   
   ============================================
   変換完了!
   Conversion completed!
   ============================================
   HTML: [フルパス]\output.html
   Resources: [フルパス]\output_files
   ```

2. 以下のファイルが作成される：
   - `output.html`
   - `output_files\style.css`
   - `output_files\script.js`
   - `output_files\image001.png`

### 2. ファイル内容の検証 / File Content Verification

#### output.html の確認

1. テキストエディタで `output.html` を開く
2. 以下を確認：
   - `<!DOCTYPE html>` で始まる
   - `<title>テストページ</title>` が含まれる（日本語）
   - `<h1>テスト</h1>` が含まれる
   - `href="output_files/style.css"` に更新されている
   - `src="output_files/image001.png"` に更新されている
   - `src="output_files/script.js"` に更新されている

#### style.css の確認

1. `output_files\style.css` を開く
2. 以下の内容が含まれる：
   ```css
   body {
       font-family: Arial, sans-serif;
       margin: 20px;
       background-color: #f0f0f0;
   }
   ```

#### script.js の確認

1. `output_files\script.js` を開く
2. 以下の内容が含まれる：
   ```javascript
   console.log('Hello from MHTML!');
   ```

#### image001.png の確認

1. `output_files\image001.png` を開く
2. 小さなPNG画像が表示される（10x10ピクセル）

### 3. ブラウザでの表示テスト / Browser Display Test

1. `output.html` をダブルクリック、またはブラウザで開く
2. 以下を確認：
   - ページタイトルが「テストページ」
   - 見出し「テスト」が表示される
   - 背景色がグレー（#f0f0f0）
   - 画像が表示される
   - ブラウザのコンソールに "Hello from MHTML!" と表示される

### 4. エラーハンドリングのテスト / Error Handling Test

#### 存在しないファイルのテスト

```cmd
cscript convert_mhtml.vbs nonexistent.mhtml
```

期待される結果：
```
エラー: 入力ファイルが見つかりません: [フルパス]\nonexistent.mhtml
Error: Input file not found: [フルパス]\nonexistent.mhtml
```

### 5. カスタム出力ディレクトリのテスト / Custom Output Directory Test

```cmd
mkdir test_output
cscript convert_mhtml.vbs input.mhtml test_output
```

期待される結果：
- `test_output\output.html` が作成される
- `test_output\output_files\` にリソースが作成される

### 6. バッチファイルのテスト / Batch File Test

```cmd
example_usage.bat
```

期待される結果：
1. メニューが表示される
2. Example 1を実行すると変換が実行される
3. 完了後、ブラウザで `output.html` が自動的に開く

## トラブルシューティング / Troubleshooting

### スクリプトが実行されない

**問題**: ダブルクリックでスクリプトが実行されない

**解決策**: コマンドプロンプトから `cscript` を使用して実行する
```cmd
cscript convert_mhtml.vbs
```

### 日本語が文字化けする

**問題**: 出力HTMLの日本語が文字化けする

**確認事項**:
1. `output.html` の文字エンコーディングがUTF-8である
2. ブラウザの文字エンコーディング設定がUTF-8である

### リソースが正しく読み込まれない

**問題**: ブラウザでCSSや画像が表示されない

**確認事項**:
1. `output_files` ディレクトリが `output.html` と同じディレクトリにある
2. リソースファイルが `output_files` 内に存在する
3. `output.html` 内の参照が `output_files/` で始まっている

## テスト結果の記録 / Test Results Documentation

テスト実施時は、以下の情報を記録してください：

- [ ] Windows バージョン: _____________
- [ ] テスト実行日時: _____________
- [ ] 基本的な変換テスト: 成功 / 失敗
- [ ] ファイル内容の検証: 成功 / 失敗
- [ ] ブラウザでの表示テスト: 成功 / 失敗
- [ ] エラーハンドリングのテスト: 成功 / 失敗
- [ ] カスタム出力ディレクトリのテスト: 成功 / 失敗
- [ ] その他の問題: _____________

## 成功基準 / Success Criteria

すべてのテストが成功した場合、以下が確認されたことになります：

✅ MHTMLファイルの正しい解析
✅ HTMLコンテンツの抽出
✅ リソースの抽出とデコード（Base64、Quoted-Printable）
✅ HTMLリファレンスの更新
✅ エラーハンドリング
✅ 日本語の正しい処理
✅ ブラウザでの正しい表示

## 追加のテストケース / Additional Test Cases

より詳細なテストを行う場合は、以下のシナリオもテストしてください：

1. **大きなMHTMLファイル**: 複数の画像を含む実際のWebページ
2. **異なるエンコーディング**: 7bit、8bitなど
3. **複雑なHTML構造**: ネストされたリソース参照
4. **特殊文字**: ファイル名に特殊文字を含むリソース
5. **重複ファイル名**: 同じ名前のリソースが複数ある場合

## サポート / Support

問題が発生した場合は、以下の情報とともにIssueを作成してください：

1. Windowsバージョン
2. 実行したコマンド
3. エラーメッセージ（あれば）
4. 入力MHTMLファイルのサンプル（可能であれば）
