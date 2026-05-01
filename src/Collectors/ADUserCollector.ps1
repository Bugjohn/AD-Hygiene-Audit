function Get-ADHygieneUsers {
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

    Get-ADUser -Filter * -Credential $Credential -Properties `
        Enabled,
        LastLogonDate,
        PasswordNeverExpires,
        PasswordNotRequired,
        CannotChangePassword,
        PasswordLastSet,
        Created,
        Modified,
        AdminCount,
        ServicePrincipalName,
        MemberOf |
    Select-Object `
        SamAccountName,
        Name,
        Enabled,
        LastLogonDate,
        PasswordNeverExpires,
        PasswordNotRequired,
        CannotChangePassword,
        PasswordLastSet,
        Created,
        Modified,
        AdminCount,
        ServicePrincipalName,
        MemberOf,
        DistinguishedName
}
