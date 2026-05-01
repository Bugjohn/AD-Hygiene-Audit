function Invoke-CheckPasswordPolicyAdvanced {
    param(
        [object]$Domain
    )

    $Findings = @()

    if (-not $Domain) {
        return $Findings
    }

    function Get-PolicyTimeValue {
        param(
            [object]$Value,
            [ValidateSet("Days", "Minutes")]
            [string]$Unit
        )

        if ($null -eq $Value) {
            return $null
        }

        if ($Value -is [timespan]) {
            if ($Unit -eq "Days") { return $Value.TotalDays }
            return $Value.TotalMinutes
        }

        try {
            return [double]$Value
        }
        catch {
            return $null
        }
    }

    function New-PasswordPolicyAdvancedFinding {
        param(
            [string]$Title,
            [string]$Severity,
            [string]$Description,
            [string]$Recommendation,
            [object]$Data
        )

        [PSCustomObject]@{
            Id             = "AD-DOM-002"
            Category       = "Domain"
            Title          = $Title
            Severity       = $Severity
            Status         = "NonCompliant"
            Description    = $Description
            Recommendation = $Recommendation
            Count          = 1
            Data           = $Data
        }
    }

    $MaxPasswordAgeDays = Get-PolicyTimeValue -Value $Domain.MaxPasswordAge -Unit Days
    if ($null -ne $MaxPasswordAgeDays -and $MaxPasswordAgeDays -gt 90) {
        $Findings += New-PasswordPolicyAdvancedFinding `
            -Title "Durée maximale du mot de passe trop longue" `
            -Severity "Medium" `
            -Description "La durée maximale dépasse 90 jours." `
            -Recommendation "Configurer une durée maximale ≤ 90 jours." `
            -Data ([PSCustomObject]@{
                Field    = "MaxPasswordAge"
                Expected = "<= 90 jours"
                Actual   = $MaxPasswordAgeDays
            })
    }

    if ($null -ne $Domain.MinPasswordLength -and $Domain.MinPasswordLength -lt 12) {
        $Findings += New-PasswordPolicyAdvancedFinding `
            -Title "Longueur minimale insuffisante" `
            -Severity "High" `
            -Description "La longueur minimale est inférieure à 12 caractères." `
            -Recommendation "Configurer une longueur minimale ≥ 12 caractères." `
            -Data ([PSCustomObject]@{
                Field    = "MinPasswordLength"
                Expected = ">= 12"
                Actual   = $Domain.MinPasswordLength
            })
    }

    if ($null -ne $Domain.PasswordHistoryCount -and $Domain.PasswordHistoryCount -lt 24) {
        $Findings += New-PasswordPolicyAdvancedFinding `
            -Title "Historique des mots de passe insuffisant" `
            -Severity "Medium" `
            -Description "L'historique est inférieur à 24." `
            -Recommendation "Configurer un historique ≥ 24." `
            -Data ([PSCustomObject]@{
                Field    = "PasswordHistoryCount"
                Expected = ">= 24"
                Actual   = $Domain.PasswordHistoryCount
            })
    }

    $LockoutDurationMinutes = Get-PolicyTimeValue -Value $Domain.LockoutDuration -Unit Minutes
    if ($null -ne $LockoutDurationMinutes -and $LockoutDurationMinutes -lt 15) {
        $Findings += New-PasswordPolicyAdvancedFinding `
            -Title "Durée de verrouillage trop courte" `
            -Severity "Medium" `
            -Description "Durée de verrouillage < 15 minutes." `
            -Recommendation "Configurer ≥ 15 minutes." `
            -Data ([PSCustomObject]@{
                Field    = "LockoutDuration"
                Expected = ">= 15 minutes"
                Actual   = $LockoutDurationMinutes
            })
    }

    return $Findings
}
