function Test-PasswordPolicy {
    param(
        [object]$Policy
    )

    [PSCustomObject]@{
        Id          = "AD-DOM-001"
        Category    = "Domain"
        Title       = "Password Policy du domaine"
        Severity    = "Info"
        Description = "Lecture de la stratégie de mot de passe du domaine."
        Count       = 1
        Data        = $Policy
        Items       = $Policy
    }
}
