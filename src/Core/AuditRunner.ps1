. "$PSScriptRoot/../Checks/Users/Check-AdminUsers.ps1"
. "$PSScriptRoot/../Checks/Computers/Check-InactiveComputers.ps1"
. "$PSScriptRoot/../Checks/Domain/Check-PasswordPolicy.ps1"
. "$PSScriptRoot/../Collectors/MockComputerCollector.ps1"
. "$PSScriptRoot/../Collectors/ADComputerCollector.ps1"
. "$PSScriptRoot/../Collectors/MockDomainCollector.ps1"
. "$PSScriptRoot/../Collectors/ADDomainCollector.ps1"

<# A réactiver en prod 
function Invoke-AuditRunner {
    param(
        [string]$OutputPath,
        [int]$InactiveDays,
        [string]$Mode
    )

    Write-Host "=== AD Hygiene Audit ===" -ForegroundColor Cyan
    Write-Host "Mode : $Mode"
    Write-Host "Seuil inactivité : $InactiveDays jours"
    Write-Host ""

    $Findings = @()

    Write-Host "[1/3] Collecte des utilisateurs AD..."
    $Users = Get-ADHygieneUsers

    Write-Host "[2/3] Analyse des comptes inactifs..."
    $Findings += Test-InactiveUsers `
        -Users $Users `
        -InactiveDays $InactiveDays

    Write-Host "[3/3] Export des rapports..."
    Export-ADHygieneJsonReport `
        -Findings $Findings `
        -OutputPath $OutputPath

    Export-ADHygieneCsvReport `
        -Findings $Findings `
        -OutputPath $OutputPath

    Write-Host ""
    Write-Host "Audit terminé." -ForegroundColor Green
    Write-Host "Rapports générés dans : $OutputPath"
} #>

<# Adaptation pour le mock #>
function Invoke-AuditRunner {
    param(
        [string]$OutputPath,
        [int]$InactiveDays,
        [string]$Mode,
        [switch]$UseMockData
    )

    Write-Host "=== AD Hygiene Audit ===" -ForegroundColor Cyan
    Write-Host "Mode : $Mode"
    Write-Host "Seuil inactivité : $InactiveDays jours"
    Write-Host "Mock mode : $UseMockData"
    Write-Host ""

    $Findings = @()
    $Groups = $null
    $RunUserChecks = $Mode -in @("Full", "Daily", "UsersOnly")
    $RunPrivilegedChecks = $Mode -in @("Full", "Daily", "PrivilegedOnly")
    $RunComputerChecks = $Mode -in @("Full", "Daily")
    $RunDomainChecks = $Mode -in @("Full", "Daily")

    if ($RunUserChecks) {
        Write-Host "[1/7] Collecte des utilisateurs..."

        if ($UseMockData) {
            $Users = Get-MockUsers
        } else {
            $Users = Get-ADHygieneUsers
        }

        Write-Host "[2/7] Analyse des comptes inactifs..."
        $Findings += Test-InactiveUsers `
            -Users $Users `
            -InactiveDays $InactiveDays
    
        Write-Host "[3/7] Analyse PasswordNeverExpires..."
        $Findings += Test-PasswordNeverExpires -Users $Users

        Write-Host "[4/7] Analyse des comptes administrateurs..."

        if ($null -eq $Groups) {
            if ($UseMockData) {
                $Groups = Get-MockPrivilegedGroups
            } else {
                $Groups = Get-ADHygienePrivilegedGroups
            }
        }

        $Findings += Test-AdminUsers `
            -Users $Users `
            -Groups $Groups
    }

    if ($RunComputerChecks) {
        Write-Host "[5/7] Analyse des ordinateurs inactifs..."

        if ($UseMockData) {
            $Computers = Get-MockComputers
        } elseif (Get-Command Get-ADHygieneComputers -ErrorAction SilentlyContinue) {
            $Computers = Get-ADHygieneComputers
        } else {
            Write-Warning "Collecteur ordinateurs indisponible. Le check AD-COMP-001 est ignoré."
            $Computers = @()
        }

        $Findings += Test-InactiveComputers `
            -Computers $Computers `
            -InactiveDays $InactiveDays
    }

    if ($RunDomainChecks) {
        Write-Host "[5/7] Lecture de la Password Policy..."

        if ($UseMockData) {
            $Policy = Get-MockPasswordPolicy
        } elseif (Get-Command Get-ADHygienePasswordPolicy -ErrorAction SilentlyContinue) {
            $Policy = Get-ADHygienePasswordPolicy
        } else {
            Write-Warning "Collecteur domain indisponible"
            $Policy = $null
        }

        if ($Policy) {
            $Findings += Test-PasswordPolicy -Policy $Policy
        }
    }

    if ($RunPrivilegedChecks) {
        Write-Host "[4/7] Analyse des groupes privilégiés..."

        if ($null -eq $Groups) {
            if ($UseMockData) {
                $Groups = Get-MockPrivilegedGroups
            } else {
                $Groups = Get-ADHygienePrivilegedGroups
            }
        }

        $Findings += Test-PrivilegedGroups -Groups $Groups

        Write-Host "[5/7] Analyse des comptes inactifs dans groupes privilégiés..."

        $Findings += Test-InactivePrivilegedUsers `
            -Groups $Groups `
            -InactiveDays $InactiveDays
    }



    Write-Host "[5/7] Calcul du score global..."
    $ScoreSummary = Get-ADHygieneScore -Findings $Findings

    Write-Host "Score global : $($ScoreSummary.Score)/100" -ForegroundColor Yellow

    Write-Host "[7/7] Export des rapports..."
    Export-ADHygieneJsonReport `
        -Findings $Findings `
        -ScoreSummary $ScoreSummary `
        -OutputPath $OutputPath

    Export-ADHygieneCsvReport `
        -Findings $Findings `
        -OutputPath $OutputPath
}
