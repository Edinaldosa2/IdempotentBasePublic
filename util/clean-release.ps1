#Requires -Version 5.1
<#
.SYNOPSIS
    Removes generated release artifacts from IdempotentBasePublic.
#>
[CmdletBinding()]
param(
    [switch]$KeepDocs,
    [switch]$KeepZip
)

$ErrorActionPreference = "Stop"
$PublicRoot = "C:\Projetos\IdempotentBasePublic"

$targets = @(
    (Join-Path $PublicRoot "app")
)

if (-not $KeepDocs) {
    $targets += @(
        (Join-Path $PublicRoot "README.md"),
        (Join-Path $PublicRoot "LICENSE"),
        (Join-Path $PublicRoot "docs"),
        (Join-Path $PublicRoot "database"),
        (Join-Path $PublicRoot ".gitignore")
    )
}

if (-not $KeepZip) {
    $targets += Join-Path $PublicRoot "releases"
}

foreach ($target in $targets) {
    if (Test-Path $target) {
        Remove-Item $target -Recurse -Force
        Write-Host "Removed: $target"
    }
}

Write-Host "Clean complete."
