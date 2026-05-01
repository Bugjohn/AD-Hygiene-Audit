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
    $RunUserChecks = $Mode -in @("Full", "Daily", "UsersOnly")
    $RunPrivilegedChecks = $Mode -in @("Full", "Daily", "PrivilegedOnly")

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
    }

    if ($RunPrivilegedChecks) {
        Write-Host "[4/7] Analyse des groupes privilégiés..."

        if ($UseMockData) {
            $Groups = Get-MockPrivilegedGroups
        } else {
            $Groups = Get-ADHygienePrivilegedGroups
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
