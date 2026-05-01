$ErrorActionPreference = "Stop"

Write-Host "=== TEST MOCK MODES ===" -ForegroundColor Cyan

function Invoke-MockAuditTest {
    param(
        [string]$Mode,
        [string]$OutputPath
    )

    if (Test-Path $OutputPath) {
        Remove-Item $OutputPath -Recurse -Force
    }

    pwsh -NoLogo -NoProfile -File ./Invoke-ADHygieneAudit.ps1 `
        -UseMockData `
        -OutputPath $OutputPath `
        -InactiveDays 90 `
        -Mode $Mode

    if (-not (Test-Path "$OutputPath/ad-hygiene-report.json")) {
        throw "Report JSON manquant pour le mode $Mode"
    }

    return Get-ChildItem "$OutputPath/*.csv" -ErrorAction SilentlyContinue
}

$UsersOutput = "/tmp/ad-hygiene-test-users"
$UsersCsv = Invoke-MockAuditTest -Mode "UsersOnly" -OutputPath $UsersOutput

if ($UsersCsv.Name -match "^AD-PRIV-") {
    throw "UsersOnly a généré des CSV privilégiés"
}

if (-not ($UsersCsv.Name -match "^AD-USR-")) {
    throw "UsersOnly n'a généré aucun CSV utilisateur"
}

Write-Host "✔ UsersOnly OK"

$PrivOutput = "/tmp/ad-hygiene-test-priv"
$PrivCsv = Invoke-MockAuditTest -Mode "PrivilegedOnly" -OutputPath $PrivOutput

if ($PrivCsv.Name -match "^AD-USR-") {
    throw "PrivilegedOnly a généré des CSV utilisateurs"
}

if (-not ($PrivCsv.Name -match "^AD-PRIV-")) {
    throw "PrivilegedOnly n'a généré aucun CSV privilégié"
}

Write-Host "✔ PrivilegedOnly OK"
Write-Host "=== TEST OK ===" -ForegroundColor Green