#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
MHTML to HTML Converter

このスクリプトは、MHTMLファイルを解析し、含まれるHTMLパートと
リソースファイル（画像、CSS、JavaScriptなど）を抽出して保存します。

使用方法:
    python mhtml_converter.py <mhtml_file_path> [output_directory]
"""

import sys
import email
import hashlib
import argparse
from pathlib import Path
from email import policy
from email.parser import BytesParser
from datetime import datetime
import base64
import quopri


class MHTMLConverter:
    """MHTMLファイルをHTMLファイルに変換するクラス"""
    
    def __init__(self, mhtml_path, output_dir=None):
        """
        初期化
        
        Args:
            mhtml_path (str): MHTMLファイルのパス
            output_dir (str): 出力ディレクトリ（デフォルト: mhtml_output）
        """
        self.mhtml_path = Path(mhtml_path)
        if not self.mhtml_path.exists():
            raise FileNotFoundError(f"MHTMLファイルが見つかりません: {mhtml_path}")
        
        if output_dir:
            self.output_dir = Path(output_dir)
        else:
            # デフォルトの出力ディレクトリ名を生成
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            self.output_dir = Path(f"mhtml_output_{timestamp}")
        
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.html_count = 0
        self.resource_count = 0
        
    def parse_mhtml(self):
        """
        MHTMLファイルを解析
        
        Returns:
            email.message.Message: 解析されたメッセージオブジェクト
        """
        try:
            with open(self.mhtml_path, 'rb') as f:
                msg = BytesParser(policy=policy.default).parse(f)
            return msg
        except Exception as e:
            raise RuntimeError(f"MHTMLファイルの解析に失敗しました: {e}")
    
    def decode_content(self, part):
        """
        パートのコンテンツをデコード
        
        Args:
            part: メールパート
            
        Returns:
            bytes: デコードされたコンテンツ
        """
        content = part.get_payload(decode=False)
        encoding = part.get('Content-Transfer-Encoding', '').lower()
        
        if isinstance(content, str):
            content = content.encode('utf-8', errors='replace')
        
        try:
            if encoding == 'base64':
                return base64.b64decode(content)
            elif encoding == 'quoted-printable':
                return quopri.decodestring(content)
            elif encoding in ['7bit', '8bit', 'binary', '']:
                return content
            else:
                # その他のエンコーディングの場合はそのまま返す
                return content
        except Exception as e:
            print(f"警告: コンテンツのデコードに失敗しました: {e}", file=sys.stderr)
            return content
    
    def get_file_extension(self, content_type):
        """
        Content-Typeから適切なファイル拡張子を取得
        
        Args:
            content_type (str): Content-Typeヘッダーの値
            
        Returns:
            str: ファイル拡張子
        """
        # 一般的なMIMEタイプと拡張子のマッピング
        mime_to_ext = {
            'text/html': 'html',
            'text/css': 'css',
            'text/javascript': 'js',
            'application/javascript': 'js',
            'application/x-javascript': 'js',
            'image/jpeg': 'jpg',
            'image/jpg': 'jpg',
            'image/png': 'png',
            'image/gif': 'gif',
            'image/svg+xml': 'svg',
            'image/webp': 'webp',
            'image/bmp': 'bmp',
            'image/x-icon': 'ico',
            'font/woff': 'woff',
            'font/woff2': 'woff2',
            'font/ttf': 'ttf',
            'font/otf': 'otf',
            'application/font-woff': 'woff',
            'application/font-woff2': 'woff2',
            'application/json': 'json',
            'application/xml': 'xml',
            'text/xml': 'xml',
            'text/plain': 'txt',
        }
        
        # Content-Typeからベースタイプを抽出（パラメータを除去）
        base_type = content_type.split(';')[0].strip().lower()
        
        return mime_to_ext.get(base_type, 'bin')
    
    def generate_unique_filename(self, content, extension='html'):
        """
        コンテンツのハッシュからユニークなファイル名を生成
        
        Args:
            content (bytes): ファイルのコンテンツ
            extension (str): ファイル拡張子
            
        Returns:
            str: ユニークなファイル名
        
        Note:
            SHA-256をファイル名の一意性のために使用
        """
        hash_obj = hashlib.sha256(content)
        hash_str = hash_obj.hexdigest()[:8]
        
        # HTML用とリソース用で別のカウンターを使用
        if extension == 'html':
            self.html_count += 1
            return f"html_part_{self.html_count}_{hash_str}.{extension}"
        else:
            self.resource_count += 1
            return f"resource_{self.resource_count}_{hash_str}.{extension}"
    
    def extract_all_parts(self, msg):
        """
        メッセージからすべてのパート（HTMLとリソース）を抽出
        
        Args:
            msg: 解析されたメッセージオブジェクト
            
        Returns:
            tuple: (html_parts, resource_parts) のタプル
        """
        html_parts = []
        resource_parts = []
        
        def process_part(part):
            """再帰的にパートを処理"""
            content_type = part.get_content_type()
            
            # HTMLコンテンツを検出
            if content_type == 'text/html':
                html_parts.append(part)
            # その他のリソースを検出（multipartとtext/plainは除外）
            elif not part.is_multipart() and content_type != 'text/plain':
                # 実際のコンテンツがあるパートのみを追加
                if part.get_payload(decode=False):
                    resource_parts.append(part)
            
            # マルチパートの場合は再帰的に処理
            if part.is_multipart():
                for subpart in part.iter_parts():
                    process_part(subpart)
        
        # メッセージ全体を処理
        if msg.is_multipart():
            for part in msg.iter_parts():
                process_part(part)
        else:
            # シングルパートの場合
            content_type = msg.get_content_type()
            if content_type == 'text/html':
                html_parts.append(msg)
            elif content_type != 'text/plain':
                resource_parts.append(msg)
        
        return html_parts, resource_parts
    
    def save_html_part(self, part, index):
        """
        HTMLパートを個別のサブディレクトリに保存
        
        Args:
            part: メールパート
            index (int): パートのインデックス
            
        Returns:
            str: 保存されたファイルのパス
        """
        try:
            # コンテンツをデコード
            content = self.decode_content(part)
            
            # Content-Typeヘッダーから文字エンコーディングを取得
            charset = part.get_content_charset()
            
            # エンコーディングを検出・変換
            if charset:
                try:
                    html_content = content.decode(charset)
                except (UnicodeDecodeError, LookupError):
                    # 指定されたcharsetでデコードできない場合はフォールバック
                    charset = None
            
            if not charset:
                # charsetが指定されていない、または失敗した場合
                try:
                    # まずUTF-8として試す
                    html_content = content.decode('utf-8')
                except UnicodeDecodeError:
                    try:
                        # 次にShift-JISを試す
                        html_content = content.decode('shift-jis')
                    except UnicodeDecodeError:
                        try:
                            # ISO-8859-1を試す
                            html_content = content.decode('iso-8859-1')
                        except UnicodeDecodeError:
                            # エラーを置換してUTF-8で強制デコード
                            html_content = content.decode('utf-8', errors='replace')
            
            # ユニークなファイル名を生成
            filename = self.generate_unique_filename(content)
            
            # サブディレクトリを作成
            subdir = self.output_dir / f"html_part_{index + 1}"
            subdir.mkdir(parents=True, exist_ok=True)
            
            # ファイルパスを生成
            file_path = subdir / filename
            
            # HTMLファイルを保存（UTF-8で保存）
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(html_content)
            
            print(f"保存しました: {file_path}")
            return str(file_path)
            
        except Exception as e:
            print(f"エラー: HTMLパート {index + 1} の保存に失敗しました: {e}", file=sys.stderr)
            return None
    
    def save_resource_part(self, part, index):
        """
        リソースパートを保存
        
        Args:
            part: メールパート
            index (int): パートのインデックス
            
        Returns:
            str: 保存されたファイルのパス
        """
        try:
            # コンテンツをデコード
            content = self.decode_content(part)
            
            # Content-Typeから拡張子を取得
            content_type = part.get_content_type()
            extension = self.get_file_extension(content_type)
            
            # ユニークなファイル名を生成
            filename = self.generate_unique_filename(content, extension)
            
            # リソース用のサブディレクトリを作成
            subdir = self.output_dir / "resources"
            subdir.mkdir(parents=True, exist_ok=True)
            
            # ファイルパスを生成
            file_path = subdir / filename
            
            # バイナリファイルとして保存
            with open(file_path, 'wb') as f:
                f.write(content)
            
            print(f"保存しました: {file_path} ({content_type})")
            return str(file_path)
            
        except Exception as e:
            print(f"エラー: リソース {index + 1} の保存に失敗しました: {e}", file=sys.stderr)
            return None
    
    def convert(self):
        """
        MHTMLファイルを変換してHTMLファイルとリソースを生成
        
        Returns:
            dict: 保存されたファイルパスの辞書 {'html': [...], 'resources': [...]}
        """
        print(f"MHTMLファイルを解析中: {self.mhtml_path}")
        
        # MHTMLを解析
        msg = self.parse_mhtml()
        
        # HTMLパートとリソースパートを抽出
        html_parts, resource_parts = self.extract_all_parts(msg)
        
        if not html_parts and not resource_parts:
            print("警告: 抽出可能なパートが見つかりませんでした")
            return {'html': [], 'resources': []}
        
        print(f"{len(html_parts)} 個のHTMLパートが見つかりました")
        print(f"{len(resource_parts)} 個のリソースが見つかりました")
        
        # 各HTMLパートを保存
        saved_html = []
        for i, part in enumerate(html_parts):
            file_path = self.save_html_part(part, i)
            if file_path:
                saved_html.append(file_path)
        
        # 各リソースパートを保存
        saved_resources = []
        for i, part in enumerate(resource_parts):
            file_path = self.save_resource_part(part, i)
            if file_path:
                saved_resources.append(file_path)
        
        print(f"\n変換完了:")
        print(f"  HTMLファイル: {len(saved_html)} 個")
        print(f"  リソースファイル: {len(saved_resources)} 個")
        print(f"出力ディレクトリ: {self.output_dir.absolute()}")
        
        return {'html': saved_html, 'resources': saved_resources}


def main():
    """メイン関数"""
    parser = argparse.ArgumentParser(
        description='MHTMLファイルをHTMLファイルに変換します',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
使用例:
  python mhtml_converter.py example.mhtml
  python mhtml_converter.py example.mhtml -o output_folder
  python mhtml_converter.py example.mhtml --output-dir my_html_files
        """
    )
    
    parser.add_argument(
        'mhtml_file',
        help='変換するMHTMLファイルのパス'
    )
    
    parser.add_argument(
        '-o', '--output-dir',
        dest='output_dir',
        default=None,
        help='出力ディレクトリ（デフォルト: mhtml_output_YYYYMMDD_HHMMSS）'
    )
    
    args = parser.parse_args()
    
    try:
        # コンバータを作成
        converter = MHTMLConverter(args.mhtml_file, args.output_dir)
        
        # 変換を実行
        converter.convert()
        
        return 0
        
    except FileNotFoundError as e:
        print(f"エラー: {e}", file=sys.stderr)
        return 1
    except RuntimeError as e:
        print(f"エラー: {e}", file=sys.stderr)
        return 1
    except Exception as e:
        print(f"予期しないエラーが発生しました: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        return 1


if __name__ == '__main__':
    sys.exit(main())
