# MHTML変換プロセス / MHTML Conversion Process

## 変換フロー / Conversion Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         input.mhtml                             │
│                                                                 │
│  From: <Saved by Windows Internet Explorer>                    │
│  MIME-Version: 1.0                                             │
│  Content-Type: multipart/related;                              │
│      boundary="----=_NextPart_..."                             │
│                                                                 │
│  ------=_NextPart_...                                          │
│  Content-Type: text/html                                       │
│  <!DOCTYPE html>...                                            │
│                                                                 │
│  ------=_NextPart_...                                          │
│  Content-Type: text/css                                        │
│  body { ... }                                                  │
│                                                                 │
│  ------=_NextPart_...                                          │
│  Content-Type: image/png                                       │
│  Content-Transfer-Encoding: base64                             │
│  iVBORw0KGgo...                                               │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ convert_mhtml.vbs
                              ▼
         ┌────────────────────────────────────┐
         │    Step 1: Parse Boundary          │
         │    Find MIME boundary marker       │
         └────────────────────────────────────┘
                              │
                              ▼
         ┌────────────────────────────────────┐
         │    Step 2: Split MIME Parts        │
         │    Separate by boundary            │
         └────────────────────────────────────┘
                              │
                              ▼
         ┌────────────────────────────────────┐
         │    Step 3: Process Each Part       │
         │    - Extract headers               │
         │    - Identify content type         │
         │    - Decode encoding               │
         └────────────────────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │                   │
                    ▼                   ▼
         ┌──────────────────┐  ┌──────────────────┐
         │   HTML Part      │  │  Resource Parts  │
         │                  │  │                  │
         │  - Decode        │  │  - Decode        │
         │  - Update refs   │  │  - Save files    │
         │  - Save HTML     │  │  - Handle dupes  │
         └──────────────────┘  └──────────────────┘
                    │                   │
                    │                   │
                    ▼                   ▼
         ┌──────────────────┐  ┌──────────────────┐
         │  output.html     │  │  output_files/   │
         │                  │  │                  │
         │  <!DOCTYPE html> │  │  ├── style.css   │
         │  <html>          │  │  ├── script.js   │
         │  <head>          │  │  └── image.png   │
         │    <link href=   │  │                  │
         │     "output_     │  │                  │
         │     files/       │  │                  │
         │     style.css">  │  │                  │
         │  </head>         │  │                  │
         │  <body>          │  │                  │
         │    <img src=     │  │                  │
         │     "output_     │  │                  │
         │     files/       │  │                  │
         │     image.png">  │  │                  │
         │  </body>         │  │                  │
         │  </html>         │  │                  │
         └──────────────────┘  └──────────────────┘
```

## 技術詳細 / Technical Details

### 1. エンコーディング処理 / Encoding Processing

```
┌─────────────────────────────────────────────────────────────┐
│ Base64 Encoding (バイナリファイル用)                        │
│                                                             │
│ Input:  iVBORw0KGgoAAAANSUhEUgAAAAoAAAAK...               │
│         ↓                                                   │
│ MSXML2.DOMDocument (Base64デコード)                        │
│         ↓                                                   │
│ ADODB.Stream (バイナリ → ファイル)                         │
│         ↓                                                   │
│ Output: image.png (バイナリファイル)                        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Quoted-Printable Encoding (テキストファイル用)             │
│                                                             │
│ Input:  =E3=83=86=E3=82=B9=E3=83=88                        │
│         ↓                                                   │
│ Decode: =XX を文字に変換                                   │
│         ↓                                                   │
│ Output: テスト                                              │
└─────────────────────────────────────────────────────────────┘
```

### 2. 参照の更新 / Reference Update

```
Before (MHTML内):
  file:///C:/test/style.css
  cid:image001.png@01D9A1B2
  file:///C:/test/script.js

After (HTML内):
  output_files/style.css
  output_files/image001.png
  output_files/script.js
```

### 3. 重複ファイル名の処理 / Duplicate Filename Handling

```
First file:   image.png      → output_files/image.png
Second file:  image.png      → output_files/image_1.png
Third file:   image.png      → output_files/image_2.png
```

## エラーハンドリング / Error Handling

```
┌────────────────────────────────────────────────┐
│ Input Validation                               │
│ ├─ File exists?                                │
│ │  └─ No → Error: File not found              │
│ └─ Yes → Continue                              │
└────────────────────────────────────────────────┘
                    │
                    ▼
┌────────────────────────────────────────────────┐
│ MHTML Parsing                                  │
│ ├─ Boundary found?                             │
│ │  └─ No → Error: Invalid MHTML format        │
│ └─ Yes → Continue                              │
└────────────────────────────────────────────────┘
                    │
                    ▼
┌────────────────────────────────────────────────┐
│ Processing Each Part                           │
│ ├─ Decoding error?                             │
│ │  └─ Skip part & log warning                 │
│ └─ Success → Save file                         │
└────────────────────────────────────────────────┘
                    │
                    ▼
┌────────────────────────────────────────────────┐
│ Output Generation                              │
│ ├─ Write error?                                │
│ │  └─ Error: Cannot write file                │
│ └─ Success → Complete                          │
└────────────────────────────────────────────────┘
```

## パフォーマンス / Performance

| ファイルサイズ | 処理時間（目安） |
|---------------|----------------|
| < 1 MB        | < 1秒          |
| 1-10 MB       | 1-5秒          |
| 10-50 MB      | 5-30秒         |
| > 50 MB       | 30秒以上       |

*Windows 10, Core i5, 8GB RAMでの測定例

## 使用するWindowsコンポーネント / Windows Components Used

```
┌─────────────────────────────────────────────────┐
│ Scripting.FileSystemObject                      │
│ ├─ ファイル/ディレクトリ操作                   │
│ └─ テキストファイルの読み書き                  │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│ MSXML2.DOMDocument                              │
│ ├─ Base64デコード                               │
│ └─ XMLノード処理                                │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│ ADODB.Stream                                    │
│ ├─ バイナリデータ処理                           │
│ ├─ 文字エンコーディング変換                     │
│ └─ ファイル保存                                 │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│ Windows Script Host                             │
│ ├─ VBScript実行環境                             │
│ ├─ コマンドライン引数処理                       │
│ └─ 標準出力                                     │
└─────────────────────────────────────────────────┘
```

## セキュリティ考慮事項 / Security Considerations

1. **ファイルパス**: 
   - 相対パスのみを使用
   - ディレクトリトラバーサル対策

2. **ファイルサイズ**:
   - 大きなファイルはメモリに注意
   - Windows制限内での動作

3. **実行権限**:
   - 出力ディレクトリへの書き込み権限が必要
   - 管理者権限は不要

4. **入力検証**:
   - MHTMLフォーマットの検証
   - 不正なバウンダリのチェック
