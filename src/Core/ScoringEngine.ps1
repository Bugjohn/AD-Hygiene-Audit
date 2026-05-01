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

    function Get-FindingCount {
        param(
            [object]$Value
        )

        if ($null -eq $Value) {
            return 0
        }

        try {
            $Count = [int]$Value
        }
        catch {
            return 0
        }

        if ($Count -lt 0) {
            return 0
        }

        return $Count
    }

    foreach ($Finding in @($Findings)) {
        $Severity = [string]$Finding.Severity

        if ($Weights.ContainsKey($Severity)) {
            $Count = Get-FindingCount -Value $Finding.Count
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
