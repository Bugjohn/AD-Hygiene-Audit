function Get-MockUsers {

    return @(
        [PSCustomObject]@{
            SamAccountName       = "jdupont"
            Name                 = "Jean Dupont"
            Enabled              = $true
            LastLogonDate        = (Get-Date).AddDays(-10)
            PasswordLastSet      = (Get-Date).AddDays(-30)
            PasswordNeverExpires = $true
            PasswordNotRequired  = $false
            CannotChangePassword = $false
            Created              = (Get-Date).AddYears(-2)
            Modified             = (Get-Date).AddDays(-15)
            AdminCount           = 0
            ServicePrincipalName = @()
            MemberOf             = @(
                "CN=Domain Admins,CN=Users,DC=lab,DC=local"
            )
            DistinguishedName    = "CN=Jean Dupont,OU=Users,DC=lab,DC=local"
        },
        [PSCustomObject]@{
            SamAccountName       = "mmartin"
            Name                 = "Marie Martin"
            Enabled              = $true
            LastLogonDate        = (Get-Date).AddDays(-200)
            PasswordLastSet      = (Get-Date).AddDays(-300)
            PasswordNeverExpires = $false
            PasswordNotRequired  = $false
            CannotChangePassword = $false
            Created              = (Get-Date).AddYears(-3)
            Modified             = (Get-Date).AddDays(-60)
            AdminCount           = 0
            ServicePrincipalName = @()
            MemberOf             = @()
            DistinguishedName    = "CN=Marie Martin,OU=Users,DC=lab,DC=local"
        },
        [PSCustomObject]@{
            SamAccountName       = "service_backup"
            Name                 = "Service Backup"
            Enabled              = $true
            LastLogonDate        = $null
            PasswordLastSet      = (Get-Date).AddDays(-400)
            PasswordNeverExpires = $true
            PasswordNotRequired  = $false
            CannotChangePassword = $false
            Created              = (Get-Date).AddYears(-5)
            Modified             = (Get-Date).AddDays(-40)
            AdminCount           = 0
            ServicePrincipalName = @(
                "MSSQLSvc/backup.lab.local:1433"
            )
            MemberOf             = @(
                "CN=Domain Admins,CN=Users,DC=lab,DC=local"
            )
            DistinguishedName    = "CN=Service Backup,OU=Service,DC=lab,DC=local"
        },
        [PSCustomObject]@{
            SamAccountName       = "admin"
            Name                 = "Administrateur"
            Enabled              = $true
            LastLogonDate        = (Get-Date).AddDays(-5)
            PasswordLastSet      = (Get-Date).AddDays(-20)
            PasswordNeverExpires = $false
            PasswordNotRequired  = $false
            CannotChangePassword = $false
            Created              = (Get-Date).AddYears(-6)
            Modified             = (Get-Date).AddDays(-5)
            AdminCount           = 1
            ServicePrincipalName = @()
            MemberOf             = @(
                "CN=Domain Admins,CN=Users,DC=lab,DC=local",
                "CN=Enterprise Admins,CN=Users,DC=lab,DC=local",
                "CN=Administrators,CN=Builtin,DC=lab,DC=local"
            )
            DistinguishedName    = "CN=Administrateur,CN=Users,DC=lab,DC=local"
        },
        [PSCustomObject]@{
            SamAccountName       = "old_admin"
            Name                 = "Ancien Administrateur"
            Enabled              = $true
            LastLogonDate        = (Get-Date).AddDays(-180)
            PasswordLastSet      = (Get-Date).AddDays(-220)
            PasswordNeverExpires = $false
            PasswordNotRequired  = $false
            CannotChangePassword = $false
            Created              = (Get-Date).AddYears(-7)
            Modified             = (Get-Date).AddDays(-120)
            AdminCount           = 1
            ServicePrincipalName = @()
            MemberOf             = @()
            DistinguishedName    = "CN=Ancien Administrateur,OU=Admins,DC=lab,DC=local"
        },
        [PSCustomObject]@{
            SamAccountName       = "disabled_admin"
            Name                 = "Admin Desactive"
            Enabled              = $false
            LastLogonDate        = (Get-Date).AddDays(-30)
            PasswordLastSet      = (Get-Date).AddDays(-120)
            PasswordNeverExpires = $false
            PasswordNotRequired  = $false
            CannotChangePassword = $false
            Created              = (Get-Date).AddYears(-4)
            Modified             = (Get-Date).AddDays(-10)
            AdminCount           = 1
            ServicePrincipalName = @()
            MemberOf             = @()
            DistinguishedName    = "CN=Admin Desactive,OU=Admins,DC=lab,DC=local"
        }
    )
}
