function Get-ADHygienePasswordPolicy {
    if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
        throw "Le module PowerShell ActiveDirectory est introuvable. Installe RSAT ou exécute ce script depuis un serveur AD."
    }

    Import-Module ActiveDirectory

    $Policy = Get-ADDefaultDomainPasswordPolicy

    [PSCustomObject]@{
        MinPasswordLength = $Policy.MinPasswordLength
        ComplexityEnabled = $Policy.ComplexityEnabled
        MaxPasswordAge    = $Policy.MaxPasswordAge.Days
        MinPasswordAge    = $Policy.MinPasswordAge.Days
        LockoutThreshold  = $Policy.LockoutThreshold
        LockoutDuration   = $Policy.LockoutDuration.TotalMinutes
    }
}
