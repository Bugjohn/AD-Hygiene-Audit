$ErrorActionPreference = "Stop"

Write-Host "=== TEST MOCK BASIC ===" -ForegroundColor Cyan

$OutputPath = "/tmp/ad-hygiene-test-basic"

if (Test-Path $OutputPath) {
    Remove-Item $OutputPath -Recurse -Force
}

pwsh -NoLogo -NoProfile -File ./Invoke-ADHygieneAudit.ps1 `
    -UseMockData `
    -OutputPath $OutputPath `
    -InactiveDays 90 `
    -Mode Full

if (-not (Test-Path "$OutputPath/report.json")) {
    throw "JSON report manquant"
}

$CsvFiles = Get-ChildItem "$OutputPath/*.csv" -ErrorAction SilentlyContinue

if (-not $CsvFiles) {
    throw "Aucun CSV généré"
}

Write-Host "✔ JSON généré"
Write-Host "✔ CSV générés : $($CsvFiles.Count)"
Write-Host "=== TEST OK ===" -ForegroundColor Green