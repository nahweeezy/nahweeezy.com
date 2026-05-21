# --------------------------------------------
# FM26 Tactic Creator - zero-dependency local HTTP server.
# Usage:  right-click -> Run with PowerShell    OR    double-click serve.bat
# Stops:  Ctrl+C in the console window
# --------------------------------------------

$port = 8000
$root = $PSScriptRoot

$mime = @{
    '.html' = 'text/html; charset=utf-8'
    '.htm'  = 'text/html; charset=utf-8'
    '.css'  = 'text/css; charset=utf-8'
    '.js'   = 'application/javascript; charset=utf-8'
    '.mjs'  = 'application/javascript; charset=utf-8'
    '.json' = 'application/json; charset=utf-8'
    '.png'  = 'image/png'
    '.jpg'  = 'image/jpeg'
    '.jpeg' = 'image/jpeg'
    '.gif'  = 'image/gif'
    '.svg'  = 'image/svg+xml'
    '.ico'  = 'image/x-icon'
    '.woff' = 'font/woff'
    '.woff2'= 'font/woff2'
    '.ttf'  = 'font/ttf'
    '.txt'  = 'text/plain; charset=utf-8'
}

$listener = New-Object System.Net.HttpListener
$prefix = "http://localhost:$port/"
$listener.Prefixes.Add($prefix)

try {
    $listener.Start()
} catch {
    Write-Host ""
    Write-Host "  Could not bind to $prefix" -ForegroundColor Red
    Write-Host "  Either port $port is in use OR you need to allow it in Windows."
    Write-Host "  Try changing `$port at the top of serve.ps1 (e.g. to 8080)."
    Write-Host ""
    pause
    exit 1
}

Clear-Host
Write-Host ""
Write-Host "  FM26 TACTIC CREATOR" -ForegroundColor Green
Write-Host "  -------------------" -ForegroundColor Green
Write-Host ""
Write-Host "  Serving:   $root"
Write-Host "  Open in browser:" -ForegroundColor Cyan
Write-Host "    http://localhost:$port/            (homepage)"
Write-Host "    http://localhost:$port/fm26.html   (creator)" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Press Ctrl+C to stop the server."
Write-Host ""

# Try to auto-open browser
Start-Process "http://localhost:$port/fm26.html"

while ($listener.IsListening) {
    try {
        $ctx = $listener.GetContext()
    } catch {
        break
    }
    $req  = $ctx.Request
    $res  = $ctx.Response

    $localPath = [Uri]::UnescapeDataString($req.Url.LocalPath)
    if ($localPath -eq '/' -or $localPath -eq '') { $localPath = '/index.html' }

    # Prevent path traversal
    $safe = $localPath.Replace('\','/').TrimStart('/')
    if ($safe -match '\.\.') {
        $res.StatusCode = 400
        $res.Close()
        continue
    }

    $file = Join-Path $root $safe
    if (Test-Path $file -PathType Leaf) {
        try {
            $bytes = [System.IO.File]::ReadAllBytes($file)
            $ext = [System.IO.Path]::GetExtension($file).ToLower()
            $type = $mime[$ext]
            if (-not $type) { $type = 'application/octet-stream' }
            $res.ContentType = $type
            $res.ContentLength64 = $bytes.Length
            $res.Headers.Add('Cache-Control', 'no-store')
            $res.OutputStream.Write($bytes, 0, $bytes.Length)
            Write-Host ("  200  " + $localPath) -ForegroundColor DarkGray
        } catch {
            $res.StatusCode = 500
            Write-Host ("  500  " + $localPath + " - " + $_.Exception.Message) -ForegroundColor Red
        }
    } else {
        $res.StatusCode = 404
        $msg = [System.Text.Encoding]::UTF8.GetBytes("404 - $localPath not found")
        $res.OutputStream.Write($msg, 0, $msg.Length)
        Write-Host ("  404  " + $localPath) -ForegroundColor DarkYellow
    }
    $res.Close()
}
