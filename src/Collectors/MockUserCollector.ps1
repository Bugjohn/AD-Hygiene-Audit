function Get-MockUsers {

    return @(
        [PSCustomObject]@{
            SamAccountName       = "jdupont"
            Name                 = "Jean Dupont"
            Enabled              = $true
            LastLogonDate        = (Get-Date).AddDays(-10)
            PasswordLastSet      = (Get-Date).AddDays(-30)
            PasswordNeverExpires = $true
            Created              = (Get-Date).AddYears(-2)
            DistinguishedName    = "CN=Jean Dupont,OU=Users,DC=lab,DC=local"
        },
        [PSCustomObject]@{
            SamAccountName       = "mmartin"
            Name                 = "Marie Martin"
            Enabled              = $true
            LastLogonDate        = (Get-Date).AddDays(-200)
            PasswordLastSet      = (Get-Date).AddDays(-300)
            Created              = (Get-Date).AddYears(-3)
            DistinguishedName    = "CN=Marie Martin,OU=Users,DC=lab,DC=local"
        },
        [PSCustomObject]@{
            SamAccountName       = "service_backup"
            Name                 = "Service Backup"
            Enabled              = $true
            LastLogonDate        = $null
            PasswordLastSet      = (Get-Date).AddDays(-400)
            PasswordNeverExpires = $true
            Created              = (Get-Date).AddYears(-5)
            DistinguishedName    = "CN=Service Backup,OU=Service,DC=lab,DC=local"
        }
    )
}