function Get-MockPasswordPolicy {

    [PSCustomObject]@{
        DomainName           = "lab.local"
        DistinguishedName    = "DC=lab,DC=local"
        MinPasswordLength    = 8
        ComplexityEnabled    = $true
        MaxPasswordAge       = [timespan]::FromDays(120)
        MinPasswordAge       = [timespan]::FromDays(1)
        PasswordHistoryCount = 12
        LockoutThreshold     = 5
        LockoutDuration      = [timespan]::FromMinutes(10)
        MaxTicketAge         = [timespan]::FromHours(12)
        MaxRenewAge          = [timespan]::FromDays(10)
        MaxServiceAge        = [timespan]::FromMinutes(720)
    }
}
