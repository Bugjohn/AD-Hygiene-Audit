function Export-ADHygieneJsonReport {
    param(
        [array]$Findings,
        [object]$ScoreSummary,
        [string]$OutputPath
    )

    $ReportPath = Join-Path $OutputPath "ad-hygiene-report.json"

    $Report = [PSCustomObject]@{
        GeneratedAt  = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Tool         = "AD-Hygiene-Audit"
        ScoreSummary = $ScoreSummary
        Findings     = $Findings
    }

    $Report |
        ConvertTo-Json -Depth 10 |
        Out-File -FilePath $ReportPath -Encoding UTF8
}