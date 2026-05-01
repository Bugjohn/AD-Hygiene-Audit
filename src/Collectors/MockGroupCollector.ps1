function Get-MockPrivilegedGroups {

    return @{
        "Domain Admins" = @(
            [PSCustomObject]@{
                SamAccountName   = "admin"
                Name             = "Administrateur"
                Enabled          = $true
                LastLogonDate    = (Get-Date).AddDays(-10)
                PasswordLastSet  = (Get-Date).AddDays(-20)
                Created          = (Get-Date).AddYears(-6)
                AdminCount       = 1
                Group            = "Domain Admins"
                DistinguishedName = "CN=Administrateur,CN=Users,DC=lab,DC=local"
            },
            [PSCustomObject]@{
                SamAccountName   = "jdupont"
                Name             = "Jean Dupont"
                Enabled          = $true
                LastLogonDate    = (Get-Date).AddDays(-200)
                PasswordLastSet  = (Get-Date).AddDays(-30)
                Created          = (Get-Date).AddYears(-2)
                AdminCount       = 0
                Group            = "Domain Admins"
                DistinguishedName = "CN=Jean Dupont,OU=Users,DC=lab,DC=local"
            },
            [PSCustomObject]@{
                SamAccountName   = "service_backup"
                Name             = "Service Backup"
                Enabled          = $true
                LastLogonDate    = $null
                PasswordLastSet  = (Get-Date).AddDays(-400)
                Created          = (Get-Date).AddYears(-5)
                AdminCount       = 0
                Group            = "Domain Admins"
                DistinguishedName = "CN=Service Backup,OU=Service,DC=lab,DC=local"
            }
        )

        "Enterprise Admins" = @(
            [PSCustomObject]@{
                SamAccountName   = "admin"
                Name             = "Administrateur"
                Enabled          = $true
                LastLogonDate    = (Get-Date).AddDays(-5)
                PasswordLastSet  = (Get-Date).AddDays(-20)
                Created          = (Get-Date).AddYears(-6)
                AdminCount       = 1
                Group            = "Enterprise Admins"
                DistinguishedName = "CN=Administrateur,CN=Users,DC=lab,DC=local"
            }
        )

        "Administrators" = @(
            [PSCustomObject]@{
                SamAccountName   = "admin"
                Name             = "Administrateur"
                Enabled          = $true
                LastLogonDate    = (Get-Date).AddDays(-1)
                PasswordLastSet  = (Get-Date).AddDays(-20)
                Created          = (Get-Date).AddYears(-6)
                AdminCount       = 1
                Group            = "Administrators"
                DistinguishedName = "CN=Administrateur,CN=Users,DC=lab,DC=local"
            }
        )
    }
}
