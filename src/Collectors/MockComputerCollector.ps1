function Get-MockComputers {

    return @(
        [PSCustomObject]@{
            SamAccountName    = "WS-001$"
            Name              = "WS-001"
            Enabled           = $true
            LastLogonDate     = (Get-Date).AddDays(-15)
            Created           = (Get-Date).AddYears(-1)
            DistinguishedName = "CN=WS-001,OU=Computers,DC=lab,DC=local"
        },
        [PSCustomObject]@{
            SamAccountName    = "WS-OLD$"
            Name              = "WS-OLD"
            Enabled           = $true
            LastLogonDate     = (Get-Date).AddDays(-180)
            Created           = (Get-Date).AddYears(-4)
            DistinguishedName = "CN=WS-OLD,OU=Computers,DC=lab,DC=local"
        }
    )
}
