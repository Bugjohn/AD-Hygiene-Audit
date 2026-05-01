function Get-MockComputers {

    return @(
        [PSCustomObject]@{
            SamAccountName    = "WS-001$"
            Name              = "WS-001"
            Enabled           = $true
            LastLogonDate     = (Get-Date).AddDays(-15)
            Created           = (Get-Date).AddYears(-1)
            Modified          = (Get-Date).AddDays(-10)
            OperatingSystem   = "Windows 11 Pro"
            OperatingSystemVersion = "10.0.22631"
            DistinguishedName = "CN=WS-001,OU=Computers,DC=lab,DC=local"
        },
        [PSCustomObject]@{
            SamAccountName    = "WS-OLD$"
            Name              = "WS-OLD"
            Enabled           = $true
            LastLogonDate     = (Get-Date).AddDays(-180)
            Created           = (Get-Date).AddYears(-4)
            Modified          = (Get-Date).AddDays(-120)
            OperatingSystem   = "Windows 7 Professional"
            OperatingSystemVersion = "6.1.7601"
            DistinguishedName = "CN=WS-OLD,OU=Computers,DC=lab,DC=local"
        },
        [PSCustomObject]@{
            SamAccountName    = "SRV-LEGACY$"
            Name              = "SRV-LEGACY"
            Enabled           = $true
            LastLogonDate     = (Get-Date).AddDays(-20)
            Created           = (Get-Date).AddYears(-8)
            Modified          = (Get-Date).AddDays(-15)
            OperatingSystem   = "Windows Server 2008 R2"
            OperatingSystemVersion = "6.1.7601"
            DistinguishedName = "CN=SRV-LEGACY,OU=Servers,DC=lab,DC=local"
        }
    )
}
