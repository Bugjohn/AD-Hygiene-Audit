$ErrorActionPreference = "Stop"

Write-Host "=== TEST MOCK CSV PRIVILEGED GROUPS ===" -ForegroundColor Cyan

$OutputPath = "/tmp/ad-hygiene-test-csv-priv"

if (Test-Path $OutputPath) {
    Remove-Item $OutputPath -Recurse -Force
}

pwsh -NoLogo -NoProfile -File ./Invoke-ADHygieneAudit.ps1 `
    -UseMockData `
    -OutputPath $OutputPath `
    -InactiveDays 90 `
    -Mode PrivilegedOnly

$ExpectedFiles = @(
    "AD-PRIV-001-PrivilegedGroups-Administrators.csv",
    "AD-PRIV-001-PrivilegedGroups-Domain_Admins.csv",
    "AD-PRIV-001-PrivilegedGroups-Enterprise_Admins.csv"
)

foreach ($File in $ExpectedFiles) {
    $Path = Join-Path $OutputPath $File

    if (-not (Test-Path $Path)) {
        throw "CSV attendu manquant : $File"
    }
}

Write-Host "✔ CSV AD-PRIV-001 séparés OK"
Write-Host "=== TEST OK ===" -ForegroundColor Green