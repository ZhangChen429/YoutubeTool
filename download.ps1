param([string]$Url, [switch]$Version)

$ErrorActionPreference = 'Stop'
function Invoke-VideoDownload {
    param([string[]]$DownloadArguments)

    $ErrorActionPreference = 'Continue'
    $MediaForbidden = $false
    $RefreshCookies = $false
    & $YtDlp @DownloadArguments -- $uri.AbsoluteUri 2>&1 | ForEach-Object {
        $Line = $_.ToString()
        if ($Line -match '^ERROR:\s+unable to download video data: HTTP Error 403\b') {
            $MediaForbidden = $true
        }
        if ($Line -match 'provided YouTube account cookies are no longer valid|Sign in to confirm you.re not a bot') {
            $RefreshCookies = $true
        }
        Write-Host $Line
    }
    $Code = $LASTEXITCODE
    if ($RefreshCookies) {
        Write-Host 'Export fresh YouTube cookies in Netscape format and drag the file onto import-cookies.bat.'
    }
    return @{ Code = $Code; MediaForbidden = $MediaForbidden }
}

try {
    if (-not $Version) {
        if (-not $Url) { $Url = Read-Host 'Paste a YouTube video URL' }
        $uri = $null
        if (-not [uri]::TryCreate($Url.Trim(), [UriKind]::Absolute, [ref]$uri) -or
            $uri.Scheme -notin @('https', 'http') -or
            ($uri.Host -ne 'youtu.be' -and $uri.Host -ne 'youtube.com' -and
             -not $uri.Host.EndsWith('.youtube.com'))) {
            throw 'Enter a valid YouTube video URL.'
        }
    }

    $Tools = Join-Path $PSScriptRoot 'tools'
    $Runtime = Join-Path $PSScriptRoot '.runtime'
    $YtDlp = Join-Path $Runtime 'yt-dlp.exe'
    if (-not (Test-Path -LiteralPath $YtDlp -PathType Leaf)) {
        New-Item -ItemType Directory -Path $Runtime -Force | Out-Null
        $TemporaryExe = Join-Path $Runtime ([guid]::NewGuid().ToString() + '.exe')
        Write-Host 'Downloading yt-dlp for Windows...'
        try {
            Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe' -OutFile $TemporaryExe
            & $TemporaryExe --version
            if ($LASTEXITCODE -ne 0) { throw 'The downloaded yt-dlp executable failed to start.' }
            Move-Item -LiteralPath $TemporaryExe -Destination $YtDlp -Force
        } finally {
            if (Test-Path -LiteralPath $TemporaryExe) { Remove-Item -LiteralPath $TemporaryExe }
        }
    }

    if ($Version) {
        & $YtDlp --version
        exit $LASTEXITCODE
    }

    $Ffmpeg = Join-Path $Tools 'ffmpeg\bin\ffmpeg.exe'
    $Deno = Join-Path $Tools 'deno\deno.exe'
    $DownloadDir = Join-Path $PSScriptRoot 'downloads'
    $Arguments = @('--ignore-config', '--no-playlist', '--paths', $DownloadDir)
    if ((Get-Item -LiteralPath $Ffmpeg -ErrorAction SilentlyContinue).Length -gt 1024) {
        $Arguments += @('--ffmpeg-location', (Split-Path -Parent $Ffmpeg))
    } else {
        $Arguments += @('--format', 'best')
    }
    if ((Get-Item -LiteralPath $Deno -ErrorAction SilentlyContinue).Length -gt 1024) {
        $Arguments += @('--js-runtimes', "deno:$Deno")
    }
    $Cookies = Join-Path $PSScriptRoot 'cookies.txt'
    if (Test-Path -LiteralPath $Cookies -PathType Leaf) {
        $Arguments += @('--cookies', $Cookies)
    }

    $Result = Invoke-VideoDownload $Arguments
    if ($Result.Code -ne 0 -and $Result.MediaForbidden -and $Arguments -notcontains '--format') {
        Write-Host 'Media request returned HTTP 403. Retrying once with a combined video and audio format...'
        $Result = Invoke-VideoDownload ($Arguments + @('--format', 'b'))
    }
    exit $Result.Code
} catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}
