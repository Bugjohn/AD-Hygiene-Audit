$ErrorActionPreference = "Stop"

Write-Host "=== TEST MOCK CONFIGPATH ===" -ForegroundColor Cyan

$ConfigPath = "/tmp/ad-hygiene-test-config.json"
$OutputPath = "/tmp/ad-hygiene-test-configpath"

if (Test-Path $OutputPath) {
    Remove-Item $OutputPath -Recurse -Force
}

@"
{
  "audit": {
    "inactiveDays": 90,
    "mode": "UsersOnly",
    "useMockData": true,
    "outputPath": "$OutputPath"
  }
}
"@ | Set-Content -Path $ConfigPath -Encoding UTF8

pwsh -NoLogo -NoProfile -File ./Invoke-ADHygieneAudit.ps1 `
    -ConfigPath $ConfigPath

if (-not (Test-Path "$OutputPath/ad-hygiene-report.json")) {
    throw "Report JSON manquant avec ConfigPath"
}

$CsvFiles = Get-ChildItem "$OutputPath/*.csv" -ErrorAction SilentlyContinue

if ($CsvFiles.Name -match "^AD-PRIV-") {
    throw "ConfigPath mode UsersOnly a généré des CSV privilégiés"
}

if (-not ($CsvFiles.Name -match "^AD-USR-")) {
    throw "ConfigPath mode UsersOnly n'a généré aucun CSV utilisateur"
}

Write-Host "✔ ConfigPath OK"
Write-Host "=== TEST OK ===" -ForegroundColor Green