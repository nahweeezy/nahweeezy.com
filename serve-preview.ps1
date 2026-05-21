# Minimal HTTP server for the Claude Preview tool — no browser pop, no prompts.
$port = 8123
$root = $PSScriptRoot

$mime = @{
    '.html' = 'text/html; charset=utf-8'
    '.htm'  = 'text/html; charset=utf-8'
    '.css'  = 'text/css; charset=utf-8'
    '.js'   = 'application/javascript; charset=utf-8'
    '.jsx'  = 'application/javascript; charset=utf-8'
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
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Serving $root on http://localhost:$port/"

while ($listener.IsListening) {
    try { $ctx = $listener.GetContext() } catch { break }
    $req = $ctx.Request; $res = $ctx.Response

    $localPath = [Uri]::UnescapeDataString($req.Url.LocalPath)
    if ($localPath -eq '/' -or $localPath -eq '') { $localPath = '/index.html' }
    $safe = $localPath.Replace('\','/').TrimStart('/')
    if ($safe -match '\.\.') { $res.StatusCode = 400; $res.Close(); continue }

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
        } catch {
            $res.StatusCode = 500
        }
    } else {
        $res.StatusCode = 404
    }
    $res.Close()
}
