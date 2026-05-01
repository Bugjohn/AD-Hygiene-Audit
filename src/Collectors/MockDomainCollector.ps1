function Get-MockPasswordPolicy {

    [PSCustomObject]@{
        MinPasswordLength = 8
        ComplexityEnabled = $true
        MaxPasswordAge    = 90
        MinPasswordAge    = 1
        LockoutThreshold  = 5
        LockoutDuration   = 30
    }
}
