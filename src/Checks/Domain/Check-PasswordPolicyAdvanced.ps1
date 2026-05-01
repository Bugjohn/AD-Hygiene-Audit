function Invoke-CheckPasswordPolicyAdvanced {
    param(
        [object]$Domain
    )

    $Findings = @()

    if (-not $Domain) {
        return $Findings
    }

    # Règles
    if ($Domain.MaxPasswordAge.Days -gt 90) {
        $Findings += @{
            Id = "AD-DOM-002"
            Severity = "Medium"
            Category = "Domain"
            Title = "Durée maximale du mot de passe trop longue"
            Description = "La durée maximale dépasse 90 jours."
            Recommendation = "Configurer une durée maximale ≤ 90 jours."
        }
    }

    if ($Domain.MinPasswordLength -lt 12) {
        $Findings += @{
            Id = "AD-DOM-002"
            Severity = "High"
            Category = "Domain"
            Title = "Longueur minimale insuffisante"
            Description = "La longueur minimale est inférieure à 12 caractères."
            Recommendation = "Configurer une longueur minimale ≥ 12 caractères."
        }
    }

    if ($Domain.PasswordHistoryCount -lt 24) {
        $Findings += @{
            Id = "AD-DOM-002"
            Severity = "Medium"
            Category = "Domain"
            Title = "Historique des mots de passe insuffisant"
            Description = "L'historique est inférieur à 24."
            Recommendation = "Configurer un historique ≥ 24."
        }
    }

    if ($Domain.LockoutDuration.TotalMinutes -lt 15) {
        $Findings += @{
            Id = "AD-DOM-002"
            Severity = "Medium"
            Category = "Domain"
            Title = "Durée de verrouillage trop courte"
            Description = "Durée de verrouillage < 15 minutes."
            Recommendation = "Configurer ≥ 15 minutes."
        }
    }

    return $Findings
}