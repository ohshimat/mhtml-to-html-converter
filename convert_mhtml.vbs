' MHTML to HTML Converter
' Windows VBScript to convert MHTML files to HTML with extracted resources
' 
' Usage: cscript convert_mhtml.vbs [input.mhtml] [output_dir]
' Default: cscript convert_mhtml.vbs input.mhtml .

Option Explicit

Dim fso, inputFile, outputDir, outputHtmlFile, resourcesDir
Dim inputFilePath, outputDirPath

' Constants
Const ForReading = 1
Const ForWriting = 2
Const TristateTrue = -1  ' Unicode
Const TristateFalse = 0  ' ASCII

' Initialize FileSystemObject
Set fso = CreateObject("Scripting.FileSystemObject")

' Parse command line arguments
If WScript.Arguments.Count >= 1 Then
    inputFilePath = WScript.Arguments(0)
Else
    inputFilePath = "input.mhtml"
End If

If WScript.Arguments.Count >= 2 Then
    outputDirPath = WScript.Arguments(1)
Else
    outputDirPath = "."
End If

' Convert to absolute paths
inputFilePath = fso.GetAbsolutePathName(inputFilePath)
outputDirPath = fso.GetAbsolutePathName(outputDirPath)

' Output file paths
outputHtmlFile = fso.BuildPath(outputDirPath, "output.html")
resourcesDir = fso.BuildPath(outputDirPath, "output_files")

' Main execution
Main()

Sub Main()
    On Error Resume Next
    
    WScript.Echo "============================================"
    WScript.Echo "MHTML to HTML Converter"
    WScript.Echo "============================================"
    WScript.Echo ""
    
    ' Validate input file
    If Not fso.FileExists(inputFilePath) Then
        WScript.Echo "エラー: 入力ファイルが見つかりません: " & inputFilePath
        WScript.Echo "Error: Input file not found: " & inputFilePath
        WScript.Quit 1
    End If
    
    WScript.Echo "入力ファイル: " & inputFilePath
    WScript.Echo "出力ディレクトリ: " & outputDirPath
    WScript.Echo ""
    
    ' Create output directory if needed
    If Not fso.FolderExists(outputDirPath) Then
        fso.CreateFolder(outputDirPath)
    End If
    
    ' Create resources directory
    If fso.FolderExists(resourcesDir) Then
        WScript.Echo "既存のリソースディレクトリを削除中..."
        fso.DeleteFolder resourcesDir, True
    End If
    fso.CreateFolder(resourcesDir)
    WScript.Echo "リソースディレクトリを作成: " & resourcesDir
    WScript.Echo ""
    
    ' Process MHTML file
    WScript.Echo "MHTMLファイルを解析中..."
    ProcessMHTMLFile inputFilePath, outputHtmlFile, resourcesDir
    
    If Err.Number <> 0 Then
        WScript.Echo "エラー: 処理中にエラーが発生しました"
        WScript.Echo "Error: " & Err.Description & " (Code: " & Err.Number & ")"
        WScript.Quit 1
    End If
    
    WScript.Echo ""
    WScript.Echo "============================================"
    WScript.Echo "変換完了!"
    WScript.Echo "Conversion completed!"
    WScript.Echo "============================================"
    WScript.Echo "HTML: " & outputHtmlFile
    WScript.Echo "Resources: " & resourcesDir
    WScript.Echo ""
End Sub

Sub ProcessMHTMLFile(inputPath, outputHtml, resourcesPath)
    Dim stream, content, parts, i, htmlContent, htmlUpdated
    Dim boundary, boundaryLine, partCount
    
    ' Read input file
    Set stream = fso.OpenTextFile(inputPath, ForReading, False, TristateFalse)
    content = stream.ReadAll()
    stream.Close()
    
    ' Find boundary
    boundary = ExtractBoundary(content)
    If boundary = "" Then
        WScript.Echo "エラー: MHTMLバウンダリが見つかりません"
        Err.Raise 1001, "ProcessMHTMLFile", "MHTML boundary not found"
        Exit Sub
    End If
    
    WScript.Echo "バウンダリ: " & boundary
    
    ' Split content by boundary
    boundaryLine = "--" & boundary
    parts = Split(content, boundaryLine)
    
    WScript.Echo "MIMEパート数: " & (UBound(parts))
    WScript.Echo ""
    
    htmlContent = ""
    partCount = 0
    
    ' Process each part
    For i = 1 To UBound(parts)
        If Len(Trim(parts(i))) > 0 And Left(Trim(parts(i)), 2) <> "--" Then
            ProcessMIMEPart parts(i), resourcesPath, htmlContent, partCount
        End If
    Next
    
    ' Update HTML references
    If htmlContent <> "" Then
        WScript.Echo ""
        WScript.Echo "HTMLファイルの参照を更新中..."
        htmlUpdated = UpdateHTMLReferences(htmlContent)
        
        ' Save HTML file
        SaveTextFile outputHtml, htmlUpdated
        WScript.Echo "HTMLファイルを保存: " & outputHtml
    Else
        WScript.Echo "警告: HTMLコンテンツが見つかりませんでした"
    End If
    
    WScript.Echo ""
    WScript.Echo "保存されたリソース: " & partCount & " ファイル"
End Sub

Function ExtractBoundary(content)
    Dim lines, i, line, pos, boundaryValue, semicolonPos
    
    ' Normalize line endings to handle different formats
    content = Replace(content, vbCrLf, vbLf)
    content = Replace(content, vbCr, vbLf)
    lines = Split(content, vbLf)
    
    For i = 0 To UBound(lines)
        line = lines(i)
        If InStr(1, LCase(line), "boundary=", vbTextCompare) > 0 Then
            pos = InStr(1, line, "boundary=", vbTextCompare)
            boundaryValue = Mid(line, pos + 9)
            
            ' Remove quotes if present
            boundaryValue = Replace(boundaryValue, """", "")
            boundaryValue = Trim(boundaryValue)
            
            ' Stop at semicolon if present (additional parameters)
            semicolonPos = InStr(boundaryValue, ";")
            If semicolonPos > 0 Then
                boundaryValue = Left(boundaryValue, semicolonPos - 1)
                boundaryValue = Trim(boundaryValue)
            End If
            
            ExtractBoundary = boundaryValue
            Exit Function
        End If
    Next
    
    ExtractBoundary = ""
End Function

Sub ProcessMIMEPart(part, resourcesPath, ByRef htmlContent, ByRef partCount)
    Dim headers, body, contentType, contentLocation, encoding, fileName
    Dim pos
    
    ' Split headers and body
    pos = InStr(part, vbCrLf & vbCrLf)
    If pos = 0 Then Exit Sub
    
    headers = Left(part, pos - 1)
    body = Mid(part, pos + 4)
    
    ' Extract headers
    contentType = ExtractHeader(headers, "Content-Type:")
    contentLocation = ExtractHeader(headers, "Content-Location:")
    encoding = ExtractHeader(headers, "Content-Transfer-Encoding:")
    
    ' Determine if this is HTML or a resource
    If InStr(1, LCase(contentType), "text/html", vbTextCompare) > 0 Then
        ' This is the main HTML
        If InStr(1, LCase(encoding), "base64", vbTextCompare) > 0 Then
            htmlContent = DecodeBase64(body)
        ElseIf InStr(1, LCase(encoding), "quoted-printable", vbTextCompare) > 0 Then
            htmlContent = DecodeQuotedPrintable(body)
        Else
            htmlContent = body
        End If
        WScript.Echo "HTMLコンテンツを抽出 (" & Len(htmlContent) & " バイト)"
    ElseIf contentLocation <> "" Then
        ' This is a resource
        fileName = GetFileNameFromLocation(contentLocation)
        If fileName <> "" Then
            fileName = GetUniqueFileName(resourcesPath, fileName)
            SaveResource resourcesPath, fileName, body, encoding, contentType
            partCount = partCount + 1
        End If
    End If
End Sub

Function ExtractHeader(headers, headerName)
    Dim lines, i, line
    
    lines = Split(headers, vbCrLf)
    
    For i = 0 To UBound(lines)
        line = lines(i)
        If InStr(1, line, headerName, vbTextCompare) = 1 Then
            ExtractHeader = Trim(Mid(line, Len(headerName) + 1))
            ' Remove semicolon and everything after for Content-Type
            If InStr(ExtractHeader, ";") > 0 Then
                ExtractHeader = Trim(Left(ExtractHeader, InStr(ExtractHeader, ";") - 1))
            End If
            Exit Function
        End If
    Next
    
    ExtractHeader = ""
End Function

Function GetFileNameFromLocation(location)
    Dim parts, fileName
    
    ' Remove protocol and domain
    location = Replace(location, "file:///", "")
    location = Replace(location, "cid:", "")
    
    ' Get last part of path
    If InStr(location, "/") > 0 Then
        parts = Split(location, "/")
        fileName = parts(UBound(parts))
    ElseIf InStr(location, "\") > 0 Then
        parts = Split(location, "\")
        fileName = parts(UBound(parts))
    Else
        fileName = location
    End If
    
    ' Decode URL encoding
    fileName = URLDecode(fileName)
    
    ' Remove query strings
    If InStr(fileName, "?") > 0 Then
        fileName = Left(fileName, InStr(fileName, "?") - 1)
    End If
    
    GetFileNameFromLocation = fileName
End Function

Function URLDecode(str)
    Dim result, i, char
    result = str
    
    ' Replace common URL encoded characters
    result = Replace(result, "%20", " ")
    result = Replace(result, "%2F", "/")
    result = Replace(result, "%5C", "\")
    result = Replace(result, "%3A", ":")
    
    URLDecode = result
End Function

Function GetUniqueFileName(dir, fileName)
    Dim baseName, extension, counter, newFileName, pos
    
    ' If file doesn't exist, return as is
    If Not fso.FileExists(fso.BuildPath(dir, fileName)) Then
        GetUniqueFileName = fileName
        Exit Function
    End If
    
    ' Split name and extension
    pos = InStrRev(fileName, ".")
    If pos > 0 Then
        baseName = Left(fileName, pos - 1)
        extension = Mid(fileName, pos)
    Else
        baseName = fileName
        extension = ""
    End If
    
    ' Find unique name
    counter = 1
    Do
        newFileName = baseName & "_" & counter & extension
        If Not fso.FileExists(fso.BuildPath(dir, newFileName)) Then
            GetUniqueFileName = newFileName
            Exit Function
        End If
        counter = counter + 1
    Loop While counter < 1000
    
    GetUniqueFileName = fileName
End Function

Sub SaveResource(dir, fileName, content, encoding, contentType)
    Dim filePath
    
    filePath = fso.BuildPath(dir, fileName)
    
    ' Decode based on encoding
    If InStr(1, LCase(encoding), "base64", vbTextCompare) > 0 Then
        SaveBase64File filePath, content
        WScript.Echo "  リソース保存 (Base64): " & fileName
    ElseIf InStr(1, LCase(encoding), "quoted-printable", vbTextCompare) > 0 Then
        SaveTextFile filePath, DecodeQuotedPrintable(content)
        WScript.Echo "  リソース保存 (Quoted-Printable): " & fileName
    Else
        SaveTextFile filePath, content
        WScript.Echo "  リソース保存: " & fileName
    End If
End Sub

Sub SaveBase64File(filePath, base64Content)
    Dim stream, cleanContent
    
    ' Remove whitespace and line breaks
    cleanContent = Replace(base64Content, vbCrLf, "")
    cleanContent = Replace(cleanContent, vbCr, "")
    cleanContent = Replace(cleanContent, vbLf, "")
    cleanContent = Replace(cleanContent, " ", "")
    cleanContent = Replace(cleanContent, vbTab, "")
    
    ' Use ADODB.Stream to decode base64
    Set stream = CreateObject("ADODB.Stream")
    stream.Type = 1 ' Binary
    stream.Open
    
    ' Use MSXML2.DOMDocument for base64 decoding
    Dim xmlDoc, node
    Set xmlDoc = CreateObject("MSXML2.DOMDocument")
    Set node = xmlDoc.createElement("b64")
    node.dataType = "bin.base64"
    node.Text = cleanContent
    
    stream.Write node.nodeTypedValue
    stream.SaveToFile filePath, 2 ' Overwrite
    stream.Close
    
    Set stream = Nothing
    Set node = Nothing
    Set xmlDoc = Nothing
End Sub

Sub SaveTextFile(filePath, content)
    Dim stream
    
    Set stream = fso.CreateTextFile(filePath, True, False)
    stream.Write content
    stream.Close
    Set stream = Nothing
End Sub

Function DecodeBase64(base64Content)
    Dim stream, cleanContent
    
    ' Remove whitespace
    cleanContent = Replace(base64Content, vbCrLf, "")
    cleanContent = Replace(cleanContent, vbCr, "")
    cleanContent = Replace(cleanContent, vbLf, "")
    cleanContent = Replace(cleanContent, " ", "")
    cleanContent = Replace(cleanContent, vbTab, "")
    
    ' Use MSXML2.DOMDocument for base64 decoding
    Dim xmlDoc, node
    Set xmlDoc = CreateObject("MSXML2.DOMDocument")
    Set node = xmlDoc.createElement("b64")
    node.dataType = "bin.base64"
    node.Text = cleanContent
    
    ' Convert binary to text
    Set stream = CreateObject("ADODB.Stream")
    stream.Type = 1 ' Binary
    stream.Open
    stream.Write node.nodeTypedValue
    stream.Position = 0
    stream.Type = 2 ' Text
    stream.Charset = "utf-8"
    DecodeBase64 = stream.ReadText()
    stream.Close
    
    Set stream = Nothing
    Set node = Nothing
    Set xmlDoc = Nothing
End Function

Function DecodeQuotedPrintable(content)
    Dim result, i, char, nextChar
    
    result = content
    
    ' Simple quoted-printable decoder
    ' Replace =XX with corresponding character
    Dim pos, nextTwoChars
    pos = InStr(result, "=")
    
    Do While pos > 0 And pos <= Len(result)
        ' Check for soft line break (= followed by CRLF, CR, or LF)
        If pos < Len(result) Then
            nextTwoChars = Mid(result, pos + 1, 2)
            If nextTwoChars = vbCrLf Then
                ' Soft line break with CRLF
                result = Left(result, pos - 1) & Mid(result, pos + 3)
            ElseIf Mid(result, pos + 1, 1) = vbCr Or Mid(result, pos + 1, 1) = vbLf Then
                ' Soft line break with CR or LF only
                result = Left(result, pos - 1) & Mid(result, pos + 2)
            ElseIf pos + 2 <= Len(result) And IsHexDigit(Mid(result, pos + 1, 1)) And IsHexDigit(Mid(result, pos + 2, 1)) Then
                ' Hex encoded character
                Dim hexValue
                hexValue = Mid(result, pos + 1, 2)
                result = Left(result, pos - 1) & Chr(CLng("&H" & hexValue)) & Mid(result, pos + 3)
            Else
                ' Invalid sequence, skip this = character
                pos = pos + 1
            End If
        End If
        pos = InStr(pos + 1, result, "=")
    Loop
    
    DecodeQuotedPrintable = result
End Function

Function IsHexDigit(char)
    IsHexDigit = False
    If char >= "0" And char <= "9" Then
        IsHexDigit = True
    ElseIf UCase(char) >= "A" And UCase(char) <= "F" Then
        IsHexDigit = True
    End If
End Function

Function UpdateHTMLReferences(html)
    Dim result
    result = html
    
    ' This is a simple implementation
    ' In a production environment, you would need more sophisticated URL rewriting
    
    ' Replace absolute file:/// references with relative paths to output_files
    result = ReplaceFileReferences(result, "file:///", "output_files/")
    
    ' Replace cid: references with relative paths
    result = ReplaceFileReferences(result, "cid:", "output_files/")
    
    UpdateHTMLReferences = result
End Function

Function ReplaceFileReferences(html, prefix, replacement)
    Dim result, pos, endPos, url, fileName
    
    result = html
    pos = InStr(1, result, prefix, vbTextCompare)
    
    Do While pos > 0
        ' Find the end of the URL (quote or space)
        endPos = FindURLEnd(result, pos)
        
        If endPos > pos Then
            url = Mid(result, pos, endPos - pos)
            fileName = GetFileNameFromLocation(url)
            
            If fileName <> "" Then
                result = Left(result, pos - 1) & replacement & fileName & Mid(result, endPos)
            End If
        End If
        
        pos = InStr(pos + Len(replacement), result, prefix, vbTextCompare)
    Loop
    
    ReplaceFileReferences = result
End Function

Function FindURLEnd(text, startPos)
    Dim i, char
    
    For i = startPos To Len(text)
        char = Mid(text, i, 1)
        If char = """" Or char = "'" Or char = " " Or char = ">" Or char = vbCrLf Or char = vbTab Then
            FindURLEnd = i
            Exit Function
        End If
    Next
    
    FindURLEnd = Len(text) + 1
End Function
