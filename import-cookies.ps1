param([string]$Source)

$ErrorActionPreference = 'Stop'
try {
    if (-not $Source) { throw 'Drag a Netscape cookies file onto import-cookies.bat.' }
    $Lines = [IO.File]::ReadAllLines((Resolve-Path -LiteralPath $Source).ProviderPath)
    if ($Lines.Count -eq 0 -or $Lines[0] -notmatch '^# (Netscape )?HTTP Cookie File\s*$') {
        throw 'Choose Netscape format when exporting cookies.'
    }

    $CookieCount = 0
    foreach ($Line in $Lines) {
        if ([string]::IsNullOrWhiteSpace($Line)) { continue }
        if ($Line.StartsWith('#') -and -not $Line.StartsWith('#HttpOnly_')) { continue }

        $Fields = $Line -split "\t"
        if ($Fields.Count -ne 7 -or $Fields[1] -cnotmatch '^(TRUE|FALSE)$' -or
            -not $Fields[2].StartsWith('/') -or $Fields[3] -cnotmatch '^(TRUE|FALSE)$' -or
            $Fields[4] -notmatch '^[0-9]+$' -or -not $Fields[5]) {
            throw 'The file contains an invalid Netscape cookie row.'
        }
        if ($Fields[0] -notmatch '^(#HttpOnly_)?\.?([a-z0-9-]+\.)*youtube\.com$') {
            throw 'Export only the current YouTube site, using Export As.'
        }
        $CookieCount++
    }
    if ($CookieCount -eq 0) { throw 'The file contains no YouTube cookies.' }

    $Destination = Join-Path $PSScriptRoot 'cookies.txt'
    $Runtime = Join-Path $PSScriptRoot '.runtime'
    New-Item -ItemType Directory -Path $Runtime -Force | Out-Null
    $TemporaryFile = Join-Path $Runtime ([guid]::NewGuid().ToString() + '.txt')
    try {
        [IO.File]::WriteAllLines($TemporaryFile, $Lines, [Text.UTF8Encoding]::new($false))
        if ([IO.File]::Exists($Destination)) {
            [IO.File]::Replace($TemporaryFile, $Destination, [NullString]::Value)
        } else {
            [IO.File]::Move($TemporaryFile, $Destination)
        }
    } finally {
        if ([IO.File]::Exists($TemporaryFile)) { [IO.File]::Delete($TemporaryFile) }
    }
    Write-Host 'YouTube cookies imported successfully.'
    exit 0
} catch {
    [Console]::Error.WriteLine('Cookie import failed: ' + $_.Exception.Message)
    exit 1
}
