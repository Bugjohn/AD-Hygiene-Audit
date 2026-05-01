function Get-ADHygieneComputers {
    if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
        throw "Le module PowerShell ActiveDirectory est introuvable. Installe RSAT ou exécute ce script depuis un serveur AD."
    }

    Import-Module ActiveDirectory

    Get-ADComputer -Filter * -Properties `
        Enabled,
        LastLogonDate,
        Created,
        Modified,
        OperatingSystem,
        OperatingSystemVersion |
    Select-Object `
        SamAccountName,
        Name,
        Enabled,
        LastLogonDate,
        Created,
        Modified,
        OperatingSystem,
        OperatingSystemVersion,
        DistinguishedName
}
