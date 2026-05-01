<# Désactivé pour le mock
param(
    [string]$OutputPath = ".\output",
    [string]$ConfigPath = ".\config\audit-config.example.json",
    [ValidateSet("Full", "Daily", "UsersOnly", "PrivilegedOnly")]
    [string]$Mode = "Full",
    [int]$InactiveDays = 90
) #>

<# A desactivé en environnement windows#>
param(
    [string]$OutputPath = "./outputs",
    [string]$ConfigPath = "./config/audit-config.example.json",
    [ValidateSet("Full", "Daily", "UsersOnly", "PrivilegedOnly")]
    [string]$Mode = "Full",
    [int]$InactiveDays = 90,
    [switch]$UseMockData
)

$ErrorActionPreference = "Stop"

. "$PSScriptRoot/src/Core/AuditRunner.ps1"
. "$PSScriptRoot/src/Collectors/ADUserCollector.ps1"
. "$PSScriptRoot/src/Collectors/MockUserCollector.ps1"
. "$PSScriptRoot/src/Checks/Users/Check-InactiveUsers.ps1"
. "$PSScriptRoot/src/Reports/JsonReport.ps1"
. "$PSScriptRoot/src/Reports/CsvReport.ps1"
. "$PSScriptRoot/src/Checks/Users/Check-PasswordNeverExpires.ps1"
. "$PSScriptRoot/src/Collectors/MockGroupCollector.ps1"
. "$PSScriptRoot/src/Checks/Groups/Check-PrivilegedGroups.ps1"
. "$PSScriptRoot/src/Core/ScoringEngine.ps1"
. "$PSScriptRoot/src/Collectors/ADGroupCollector.ps1"
. "$PSScriptRoot/src/Checks/Groups/Check-InactivePrivilegedUsers.ps1"




if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath | Out-Null
}

Invoke-AuditRunner `
    -OutputPath $OutputPath `
    -InactiveDays $InactiveDays `
    -Mode $Mode `
    -UseMockData:$UseMockData