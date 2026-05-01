function Get-ADHygienePasswordPolicy {
    if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
        throw "Le module PowerShell ActiveDirectory est introuvable. Installe RSAT ou exécute ce script depuis un serveur AD."
    }

    Import-Module ActiveDirectory
    $CredentialFile = $Config.activeDirectory.credentialFile

    if ([string]::IsNullOrWhiteSpace($CredentialFile)) {
        throw "Aucun fichier de credential Active Directory n'est configuré (activeDirectory.credentialFile)."
    }

    if (-not (Test-Path -Path $CredentialFile)) {
        throw "Fichier de credential Active Directory introuvable : $CredentialFile"
    }

    $Credential = Import-Clixml -Path $CredentialFile

    if ($null -eq $Credential -or -not ($Credential -is [System.Management.Automation.PSCredential]) -or [string]::IsNullOrWhiteSpace($Credential.UserName)) {
        throw "Impossible de charger le credential depuis $CredentialFile"
    }

    $Policy = Get-ADDefaultDomainPasswordPolicy -Credential $Credential

    [PSCustomObject]@{
        MinPasswordLength = $Policy.MinPasswordLength
        ComplexityEnabled = $Policy.ComplexityEnabled
        MaxPasswordAge    = $Policy.MaxPasswordAge.Days
        MinPasswordAge    = $Policy.MinPasswordAge.Days
        LockoutThreshold  = $Policy.LockoutThreshold
        LockoutDuration   = $Policy.LockoutDuration.TotalMinutes
    }
}
