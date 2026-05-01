function Get-MockPrivilegedGroups {

    return @{
        "Domain Admins" = @(
            [PSCustomObject]@{
                SamAccountName = "admin"
                Name           = "Administrateur"
                Enabled        = $true
                LastLogonDate  = (Get-Date).AddDays(-10)
            },
            [PSCustomObject]@{
                SamAccountName = "jdupont"
                Name           = "Jean Dupont"
                Enabled        = $true
                LastLogonDate  = (Get-Date).AddDays(-200) # 👈 inactif
            }
        )

        "Enterprise Admins" = @(
            [PSCustomObject]@{
                SamAccountName = "admin"
                Name           = "Administrateur"
                Enabled        = $true
                LastLogonDate  = (Get-Date).AddDays(-5)
            }
        )

        "Administrators" = @(
            [PSCustomObject]@{
                SamAccountName = "admin"
                Name           = "Administrateur"
                Enabled        = $true
                LastLogonDate  = (Get-Date).AddDays(-1)
            }
        )
    }
}