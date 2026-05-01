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

if (Test-Path $ConfigPath) {
    try {
        $Config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
        $AuditConfig = $Config.audit

        if ($AuditConfig) {
            if (-not $PSBoundParameters.ContainsKey("InactiveDays") -and $null -ne $AuditConfig.inactiveDays) {
                $InactiveDays = [int]$AuditConfig.inactiveDays
            }

            if (-not $PSBoundParameters.ContainsKey("Mode") -and $AuditConfig.mode) {
                $Mode = [string]$AuditConfig.mode
            }

            if (-not $PSBoundParameters.ContainsKey("UseMockData") -and $null -ne $AuditConfig.useMockData) {
                $UseMockData = [bool]$AuditConfig.useMockData
            }

            if (-not $PSBoundParameters.ContainsKey("OutputPath") -and $AuditConfig.outputPath) {
                $OutputPath = [string]$AuditConfig.outputPath
            }
        }
    }
    catch {
        Write-Warning "Impossible de lire le fichier de configuration '$ConfigPath'. Les valeurs par défaut ou CLI seront utilisées."
    }
} else {
    Write-Warning "Fichier de configuration introuvable : '$ConfigPath'. Les valeurs par défaut ou CLI seront utilisées."
}

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
