@echo off
REM MHTML to HTML Converter - Example Usage
REM This batch file demonstrates how to use the converter

echo ==========================================
echo MHTML to HTML Converter - Usage Examples
echo ==========================================
echo.

echo Example 1: Convert default input.mhtml
echo Command: cscript convert_mhtml.vbs
echo.
echo Press any key to run Example 1...
pause >nul
cscript //nologo convert_mhtml.vbs
echo.

echo ==========================================
echo.
echo Example 2: Convert custom MHTML file
echo Command: cscript convert_mhtml.vbs myfile.mhtml
echo.
echo (Skipping - requires custom file)
echo.

echo ==========================================
echo.
echo Example 3: Convert to custom output directory
echo Command: cscript convert_mhtml.vbs input.mhtml C:\output
echo.
echo (Skipping - would create files in C:\output)
echo.

echo ==========================================
echo Conversion Complete!
echo ==========================================
echo.
echo Check the following files:
echo   - output.html
echo   - output_files\ (directory with resources)
echo.
echo Press any key to open output.html in browser...
pause >nul

if exist output.html (
    start output.html
) else (
    echo ERROR: output.html not found
)

echo.
echo Done!
pause
