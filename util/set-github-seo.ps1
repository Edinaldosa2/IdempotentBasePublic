#Requires -Version 5.1
<#
.SYNOPSIS
    Sets GitHub repository description and topics for SEO/discoverability.

.DESCRIPTION
    Updates the About section (description + topics) on GitHub for IdempotentBasePublic.
    Requires a GitHub token with repo scope (or use Git Credential Manager via git push auth).

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File util\set-github-seo.ps1
#>
[CmdletBinding()]
param(
    [string]$Owner = "Edinaldosa2",
    [string]$Repo = "IdempotentBasePublic",
    [string]$Token = $env:GITHUB_TOKEN
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($Token)) {
    $credInput = "protocol=https`nhost=github.com`n`n"
    $credOutput = ($credInput | git credential fill 2>$null) -join "`n"
    $match = [regex]::Match($credOutput, 'password=(.+)')
    if ($match.Success) {
        $Token = $match.Groups[1].Value.Trim()
    }
}

if ([string]::IsNullOrWhiteSpace($Token)) {
    throw "GitHub token not found. Set GITHUB_TOKEN or authenticate git push first."
}

$description = "Safe database schema comparison, idempotent migration, DEV-PROD synchronization and SQL Server backup for Windows (.NET/WPF). Built for DBAs and DevOps."
$topics = @(
    "sqlserver", "database", "migration", "idempotent", "schema", "backup",
    "devops", "dotnet", "wpf", "dba", "database-tools", "synchronization", "ai"
)

$headers = @{
    Authorization = "Bearer $Token"
    Accept        = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

$topicHeaders = @{
    Authorization = "Bearer $Token"
    Accept        = "application/vnd.github.mercy-preview+json"
}

Write-Host "Updating repository description..." -ForegroundColor Cyan
Invoke-RestMethod `
    -Uri "https://api.github.com/repos/$Owner/$Repo" `
    -Method Patch `
    -Headers $headers `
    -Body (@{ description = $description } | ConvertTo-Json) `
    -ContentType "application/json" | Out-Null

Write-Host "Updating repository topics..." -ForegroundColor Cyan
$result = Invoke-RestMethod `
    -Uri "https://api.github.com/repos/$Owner/$Repo/topics" `
    -Method Put `
    -Headers $topicHeaders `
    -Body (@{ names = $topics } | ConvertTo-Json) `
    -ContentType "application/json"

Write-Host "Done." -ForegroundColor Green
Write-Host "Description: $description"
Write-Host "Topics: $($result.names -join ', ')"
