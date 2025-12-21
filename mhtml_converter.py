#!/usr/bin/env python3
"""
MHTML to HTML Converter

This script converts MHTML (MIME HTML) files to standalone HTML files.
MHTML files contain HTML content along with embedded resources like images,
CSS, and JavaScript in a single file using the MIME multipart format.
"""

import sys
import os
import email
import base64
import quopri
from email import policy
from email.parser import BytesParser
from pathlib import Path
from urllib.parse import unquote


def parse_mhtml(mhtml_path):
    """
    Parse an MHTML file and extract its parts.
    
    Args:
        mhtml_path: Path to the MHTML file
        
    Returns:
        A tuple of (main_html_content, resources_dict)
        where resources_dict maps Content-Location to (content_type, data)
    """
    with open(mhtml_path, 'rb') as f:
        msg = BytesParser(policy=policy.default).parse(f)
    
    main_html = None
    resources = {}
    
    # Process all parts of the multipart message
    if msg.is_multipart():
        for part in msg.walk():
            content_type = part.get_content_type()
            content_location = part.get('Content-Location', '')
            content_transfer_encoding = part.get('Content-Transfer-Encoding', '').lower()
            
            # Get the content
            payload = part.get_payload(decode=False)
            
            # Decode based on Content-Transfer-Encoding
            if isinstance(payload, str):
                payload = payload.encode('utf-8')
            
            if content_transfer_encoding == 'base64':
                try:
                    decoded_payload = base64.b64decode(payload)
                except:
                    decoded_payload = payload
            elif content_transfer_encoding == 'quoted-printable':
                decoded_payload = quopri.decodestring(payload)
            else:
                decoded_payload = payload
            
            # Store the main HTML
            if content_type == 'text/html' and main_html is None:
                main_html = decoded_payload
            
            # Store resources with their location
            if content_location:
                resources[content_location] = (content_type, decoded_payload)
    else:
        # Single part message (just HTML)
        main_html = msg.get_payload(decode=True)
    
    return main_html, resources


def embed_resources(html_content, resources):
    """
    Embed external resources as data URIs in the HTML content.
    
    Args:
        html_content: The main HTML content as bytes
        resources: Dictionary mapping Content-Location to (content_type, data)
        
    Returns:
        Modified HTML content with embedded resources
    """
    if isinstance(html_content, bytes):
        html_text = html_content.decode('utf-8', errors='ignore')
    else:
        html_text = html_content
    
    # Create a mapping of URLs to data URIs
    url_to_data_uri = {}
    
    for location, (content_type, data) in resources.items():
        # For CSS files, replace URLs inside them first
        if content_type == 'text/css' and isinstance(data, bytes):
            css_text = data.decode('utf-8', errors='ignore')
            # Replace URLs in the CSS with data URIs from resources
            for css_url, (css_res_type, css_res_data) in resources.items():
                if css_res_type.startswith('image/') or css_res_type.startswith('font/'):
                    css_res_b64 = base64.b64encode(css_res_data).decode('ascii')
                    css_res_data_uri = f"data:{css_res_type};base64,{css_res_b64}"
                    # Replace various CSS url() formats
                    css_text = css_text.replace(f"url('{css_url}')", f"url('{css_res_data_uri}')")
                    css_text = css_text.replace(f'url("{css_url}")', f'url("{css_res_data_uri}")')
                    css_text = css_text.replace(f'url({css_url})', f'url({css_res_data_uri})')
            data = css_text.encode('utf-8')
        
        # Convert binary data to base64 data URI
        if isinstance(data, bytes):
            b64_data = base64.b64encode(data).decode('ascii')
            data_uri = f"data:{content_type};base64,{b64_data}"
            url_to_data_uri[location] = data_uri
    
    # Replace references to external resources with data URIs
    for url, data_uri in url_to_data_uri.items():
        # Handle various URL formats - using simple string replace
        replacements = [
            (f'src="{url}"', f'src="{data_uri}"'),
            (f"src='{url}'", f"src='{data_uri}'"),
            (f'href="{url}"', f'href="{data_uri}"'),
            (f"href='{url}'", f"href='{data_uri}'"),
            (f'url({url})', f'url({data_uri})'),
            (f'url("{url}")', f'url("{data_uri}")'),
            (f"url('{url}')", f"url('{data_uri}')"),
        ]
        
        for pattern, replacement in replacements:
            html_text = html_text.replace(pattern, replacement)
    
    return html_text


def convert_mhtml_to_html(mhtml_path, output_path=None):
    """
    Convert an MHTML file to a standalone HTML file.
    
    Args:
        mhtml_path: Path to the input MHTML file
        output_path: Path to the output HTML file (optional)
        
    Returns:
        Path to the generated HTML file
    """
    # Parse the MHTML file
    html_content, resources = parse_mhtml(mhtml_path)
    
    if html_content is None:
        raise ValueError("No HTML content found in MHTML file")
    
    # Embed resources in the HTML
    final_html = embed_resources(html_content, resources)
    
    # Determine output path
    if output_path is None:
        mhtml_file = Path(mhtml_path)
        output_path = mhtml_file.with_suffix('.html')
    
    # Write the output HTML file
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(final_html)
    
    return output_path


def main():
    """Main entry point for the command-line interface."""
    if len(sys.argv) < 2:
        print("Usage: python mhtml_converter.py <input.mhtml> [output.html]")
        print("\nConverts an MHTML file to a standalone HTML file.")
        print("\nArguments:")
        print("  input.mhtml   Path to the input MHTML file")
        print("  output.html   Path to the output HTML file (optional)")
        print("                If not provided, uses the same name as input with .html extension")
        sys.exit(1)
    
    mhtml_path = sys.argv[1]
    output_path = sys.argv[2] if len(sys.argv) > 2 else None
    
    if not os.path.exists(mhtml_path):
        print(f"Error: File '{mhtml_path}' not found")
        sys.exit(1)
    
    try:
        output_file = convert_mhtml_to_html(mhtml_path, output_path)
        print(f"Successfully converted '{mhtml_path}' to '{output_file}'")
    except Exception as e:
        print(f"Error converting file: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == '__main__':
    main()
