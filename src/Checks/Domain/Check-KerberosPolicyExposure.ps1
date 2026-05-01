function Test-KerberosPolicyExposure {
    param(
        [object]$Domain,
        [array]$Users
    )

    $Findings = @()

    function Get-TimePolicyValue {
        param(
            [object]$Value,
            [ValidateSet("Hours", "Days", "Minutes")]
            [string]$Unit
        )

        if ($null -eq $Value) {
            return $null
        }

        if ($Value -is [timespan]) {
            if ($Unit -eq "Hours") { return $Value.TotalHours }
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

    if ($Domain) {
        $MaxTicketAge = Get-TimePolicyValue -Value $Domain.MaxTicketAge -Unit Hours
        if ($null -ne $MaxTicketAge -and $MaxTicketAge -gt 10) {
            $Findings += [PSCustomObject]@{
                Id             = "AD-DOM-003"
                Category       = "Domain"
                Title          = "Duree des tickets utilisateur trop longue"
                Severity       = "Medium"
                Status         = "NonCompliant"
                Description    = "MaxTicketAge depasse 10 heures."
                Recommendation = "Configurer MaxTicketAge a 10 heures ou moins."
                Count          = 1
                Data           = [PSCustomObject]@{
                    Field    = "MaxTicketAge"
                    Expected = "<= 10 heures"
                    Actual   = $MaxTicketAge
                }
            }
        }

        $MaxRenewAge = Get-TimePolicyValue -Value $Domain.MaxRenewAge -Unit Days
        if ($null -ne $MaxRenewAge -and $MaxRenewAge -gt 7) {
            $Findings += [PSCustomObject]@{
                Id             = "AD-DOM-003"
                Category       = "Domain"
                Title          = "Duree de renouvellement Kerberos trop longue"
                Severity       = "Medium"
                Status         = "NonCompliant"
                Description    = "MaxRenewAge depasse 7 jours."
                Recommendation = "Configurer MaxRenewAge a 7 jours ou moins."
                Count          = 1
                Data           = [PSCustomObject]@{
                    Field    = "MaxRenewAge"
                    Expected = "<= 7 jours"
                    Actual   = $MaxRenewAge
                }
            }
        }

        $MaxServiceAge = Get-TimePolicyValue -Value $Domain.MaxServiceAge -Unit Minutes
        if ($null -ne $MaxServiceAge -and $MaxServiceAge -gt 600) {
            $Findings += [PSCustomObject]@{
                Id             = "AD-DOM-003"
                Category       = "Domain"
                Title          = "Duree des tickets de service trop longue"
                Severity       = "Medium"
                Status         = "NonCompliant"
                Description    = "MaxServiceAge depasse 600 minutes."
                Recommendation = "Configurer MaxServiceAge a 600 minutes ou moins."
                Count          = 1
                Data           = [PSCustomObject]@{
                    Field    = "MaxServiceAge"
                    Expected = "<= 600 minutes"
                    Actual   = $MaxServiceAge
                }
            }
        }
    }

    $UsersWithSpn = @($Users | Where-Object {
        -not [string]::IsNullOrWhiteSpace(($_.ServicePrincipalName -join ""))
    })

    if ($UsersWithSpn.Count -gt 0) {
        $Findings += [PSCustomObject]@{
            Id             = "AD-DOM-003"
            Category       = "Domain"
            Title          = "Comptes avec SPN exposes au Kerberoasting"
            Severity       = "High"
            Status         = "NonCompliant"
            Description    = "Comptes disposant d'un ServicePrincipalName, augmentant la surface Kerberoasting."
            Recommendation = "Limiter les SPN aux comptes necessaires et utiliser des mots de passe robustes ou gMSA."
            Count          = $UsersWithSpn.Count
            Items          = $UsersWithSpn
        }
    }

    return $Findings
}
