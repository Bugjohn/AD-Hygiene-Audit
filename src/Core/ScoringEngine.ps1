function Get-ADHygieneScore {
    param(
        [array]$Findings
    )

    $Weights = @{
        "Critical" = 20
        "High"     = 10
        "Medium"   = 5
        "Low"      = 2
        "Info"     = 0
    }

    $TotalPenalty = 0

    foreach ($Finding in $Findings) {
        $Severity = [string]$Finding.Severity
        $Count = [int]$Finding.Count

        if ($Weights.ContainsKey($Severity)) {
            $TotalPenalty += ($Weights[$Severity] * $Count)
        }
    }

    $Score = 100 - $TotalPenalty

    if ($Score -lt 0) {
        $Score = 0
    }

    $Summary = [PSCustomObject]@{
        Score    = $Score
        Critical = ($Findings | Where-Object { $_.Severity -eq "Critical" } | Measure-Object).Count
        High     = ($Findings | Where-Object { $_.Severity -eq "High" } | Measure-Object).Count
        Medium   = ($Findings | Where-Object { $_.Severity -eq "Medium" } | Measure-Object).Count
        Low      = ($Findings | Where-Object { $_.Severity -eq "Low" } | Measure-Object).Count
        Info     = ($Findings | Where-Object { $_.Severity -eq "Info" } | Measure-Object).Count
    }

    return $Summary
}