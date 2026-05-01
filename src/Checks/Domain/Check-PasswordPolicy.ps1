function Test-PasswordPolicy {
    param(
        [object]$Policy
    )

    $Rules = @(
        [PSCustomObject]@{
            Name      = "Longueur minimale du mot de passe"
            Expected  = ">= 12"
            Actual    = $Policy.MinPasswordLength
            Compliant = $Policy.MinPasswordLength -ge 12
        },
        [PSCustomObject]@{
            Name      = "Complexité des mots de passe"
            Expected  = "true"
            Actual    = $Policy.ComplexityEnabled
            Compliant = $Policy.ComplexityEnabled -eq $true
        },
        [PSCustomObject]@{
            Name      = "Seuil de verrouillage"
            Expected  = "> 0"
            Actual    = $Policy.LockoutThreshold
            Compliant = $Policy.LockoutThreshold -gt 0
        }
    )

    $Recommendations = @()

    if ($Policy.MinPasswordLength -lt 12) {
        $Recommendations += "Définir une longueur minimale de mot de passe d’au moins 12 caractères."
    }

    if ($Policy.ComplexityEnabled -ne $true) {
        $Recommendations += "Activer la complexité des mots de passe."
    }

    if ($Policy.LockoutThreshold -le 0) {
        $Recommendations += "Définir un seuil de verrouillage pour limiter les attaques par force brute."
    }

    $NonCompliantCount = ($Rules | Where-Object { -not $_.Compliant } | Measure-Object).Count
    $Status = if ($NonCompliantCount -eq 0) { "Compliant" } else { "NonCompliant" }
    $Severity = if ($NonCompliantCount -eq 0) { "Info" } else { "Medium" }

    [PSCustomObject]@{
        Id          = "AD-DOM-001"
        Category    = "Domain"
        Title       = "Password Policy du domaine"
        Severity    = $Severity
        Description = "Analyse de conformité minimale de la stratégie de mot de passe du domaine."
        Count       = $NonCompliantCount
        Status      = $Status
        Data        = [PSCustomObject]@{
            Policy          = $Policy
            Rules           = $Rules
            Recommendations = $Recommendations
        }
        Items       = $Rules
    }
}
