function Get-ADHygieneUsers {
    if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
        throw "Le module PowerShell ActiveDirectory est introuvable. Installe RSAT ou exécute ce script depuis un serveur AD."
    }

    Import-Module ActiveDirectory

    Get-ADUser -Filter * -Properties `
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