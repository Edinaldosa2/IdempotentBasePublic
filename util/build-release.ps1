#Requires -Version 5.1
<#
.SYNOPSIS
    Builds the IdempotentBase public release package.

.DESCRIPTION
    Publishes the desktop app from the development repository into
    C:\Projetos\IdempotentBasePublic\app as IdempotentBase.exe,
    then copies documentation, license, and connection samples.

    Run from anywhere:
      powershell -ExecutionPolicy Bypass -File C:\Projetos\IdempotentBasePublic\util\build-release.ps1

    Optional parameters:
      -Version "1.0.0"   Creates releases\IdempotentBase-v1.0.0-win-x64.zip
      -SkipZip           Skip ZIP creation
#>
[CmdletBinding()]
param(
    [string]$Version = "",
    [switch]$SkipZip
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$DevRoot    = "C:\Projetos\IdempotentBase"
$PublicRoot = "C:\Projetos\IdempotentBasePublic"
$UtilRoot   = Join-Path $PublicRoot "util"
$AppOut     = Join-Path $PublicRoot "app"
$DocsOut    = Join-Path $PublicRoot "docs"
$DatabaseOut = Join-Path $PublicRoot "database"
$ReleasesOut = Join-Path $PublicRoot "releases"
$Project    = Join-Path $DevRoot "src\IdempotentBase.Desktop\IdempotentBase.Desktop.csproj"

function Write-Step([string]$Message) {
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Remove-TreeIfExists([string]$Path) {
    if (Test-Path $Path) {
        Remove-Item $Path -Recurse -Force
    }
}

function Copy-Tree([string]$Source, [string]$Destination) {
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    Copy-Item -Path (Join-Path $Source "*") -Destination $Destination -Recurse -Force
}

Write-Step "Validating development repository"
if (-not (Test-Path $Project)) {
    throw "Desktop project not found: $Project"
}

Write-Step "Publishing Release build to $AppOut"
Remove-TreeIfExists $AppOut
New-Item -ItemType Directory -Path $AppOut -Force | Out-Null

Push-Location $DevRoot
try {
    dotnet publish $Project `
        -c Release `
        -o $AppOut `
        --nologo
    if ($LASTEXITCODE -ne 0) {
        throw "dotnet publish failed with exit code $LASTEXITCODE"
    }
}
finally {
    Pop-Location
}

$publishedExe = Join-Path $AppOut "IdempotentBase.Desktop.exe"
$exePath = Join-Path $AppOut "IdempotentBase.exe"

if (-not (Test-Path $publishedExe)) {
    throw "Expected executable not found: $publishedExe"
}

if (Test-Path $exePath) {
    Remove-Item $exePath -Force
}

Rename-Item -Path $publishedExe -NewName "IdempotentBase.exe"
Write-Host "Renamed IdempotentBase.Desktop.exe -> IdempotentBase.exe"

$publishedConfig = Join-Path $AppOut "IdempotentBase.Desktop.exe.config"
$configPath = Join-Path $AppOut "IdempotentBase.exe.config"
if (Test-Path $publishedConfig) {
    if (Test-Path $configPath) {
        Remove-Item $configPath -Force
    }
    Rename-Item -Path $publishedConfig -NewName "IdempotentBase.exe.config"
    Write-Host "Renamed IdempotentBase.Desktop.exe.config -> IdempotentBase.exe.config"
}

Get-ChildItem $AppOut -Filter "*.pdb" -Recurse | Remove-Item -Force
Write-Host "Removed debug symbol files (.pdb) from app folder"

Write-Step "Copying LICENSE (keeping public README.md)"
Copy-Item (Join-Path $DevRoot "LICENSE") (Join-Path $PublicRoot "LICENSE") -Force

Write-Step "Copying documentation"
Remove-TreeIfExists $DocsOut
Copy-Tree (Join-Path $DevRoot "docs") $DocsOut

Write-Step "Copying database connection samples"
Remove-TreeIfExists $DatabaseOut
Copy-Tree (Join-Path $DevRoot "database") $DatabaseOut

Get-ChildItem $DatabaseOut -Recurse -Filter "connections.json" -ErrorAction SilentlyContinue |
    Remove-Item -Force

Get-ChildItem $AppOut -Recurse -Filter "connections.json" -ErrorAction SilentlyContinue |
    Remove-Item -Force

Write-Step "Updating .gitignore for public repository"
$gitignore = @"
# === Segredos e dados locais do usuario ===
database/**/connections.json
**/connections.json
!**/connections.sample.json
*.env
.env.*
connection-strings.local.json
**/secrets/

# === Logs e runtime ===
**/logs/
*.log

# === Releases binarios (subir so no GitHub Releases, nao no git) ===
releases/
releases/**

# === Build temporario / lixo ===
*.pdb
*.tmp
*.bak
*.user
*.suo
.vs/
bin/
obj/

# === Sistema operacional ===
Thumbs.db
ehthumbs.db
Desktop.ini
`$RECYCLE.BIN/

# === Opcional: se no futuro gerar staging fora de app/ ===
staging/
temp/
"@
Set-Content -Path (Join-Path $PublicRoot ".gitignore") -Value $gitignore -Encoding UTF8

if (-not $SkipZip) {
    $zipName = if ([string]::IsNullOrWhiteSpace($Version)) {
        "IdempotentBase-win-x64.zip"
    } else {
        "IdempotentBase-v$Version-win-x64.zip"
    }

    Write-Step "Creating release ZIP: $zipName"
    New-Item -ItemType Directory -Path $ReleasesOut -Force | Out-Null
    $zipPath = Join-Path $ReleasesOut $zipName
    if (Test-Path $zipPath) {
        Remove-Item $zipPath -Force
    }

    $staging = Join-Path $env:TEMP ("IdempotentBase-staging-" + [guid]::NewGuid().ToString("N"))
    try {
        New-Item -ItemType Directory -Path $staging -Force | Out-Null
        Copy-Item (Join-Path $PublicRoot "README.md") $staging -Force
        Copy-Item (Join-Path $PublicRoot "LICENSE")   $staging -Force
        Copy-Item $DocsOut     (Join-Path $staging "docs")     -Recurse -Force
        Copy-Item $DatabaseOut (Join-Path $staging "database") -Recurse -Force
        Copy-Item $AppOut      (Join-Path $staging "app")      -Recurse -Force
        Compress-Archive -Path (Join-Path $staging "*") -DestinationPath $zipPath -Force
    }
    finally {
        Remove-TreeIfExists $staging
    }
}

Write-Step "Release package ready"
Write-Host "  Executable : $exePath"
Write-Host "  README     : $(Join-Path $PublicRoot 'README.md')"
Write-Host "  LICENSE    : $(Join-Path $PublicRoot 'LICENSE')"
Write-Host "  Docs       : $DocsOut"
Write-Host "  Samples    : $DatabaseOut"
if (-not $SkipZip) {
    Write-Host "  ZIP        : $(Join-Path $ReleasesOut $zipName)"
}
Write-Host ""
Write-Host "Test run:" -ForegroundColor Green
Write-Host "  & '$exePath'"
