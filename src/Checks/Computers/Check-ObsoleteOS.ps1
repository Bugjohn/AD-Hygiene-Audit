function Test-ObsoleteOperatingSystems {
    param(
        [array]$Computers
    )

    $ObsoletePatterns = @(
        "Windows 7",
        "Windows XP",
        "Windows Server 2008",
        "Windows Server 2003"
    )

    $ObsoleteComputers = @($Computers | Where-Object {
        $OperatingSystem = [string]$_.OperatingSystem
        $ObsoletePatterns | Where-Object { $OperatingSystem -match [regex]::Escape($_) }
    })

    $Count = ($ObsoleteComputers | Measure-Object).Count
    $Status = if ($Count -gt 0) { "NonCompliant" } else { "Compliant" }
    $Severity = if ($Count -gt 0) { "High" } else { "Info" }

    [PSCustomObject]@{
        Id              = "AD-COMP-002"
        Category        = "Computers"
        Title           = "Systèmes d’exploitation obsolètes"
        Severity        = $Severity
        Description     = "Détection des ordinateurs utilisant un système d'exploitation obsolète."
        Count           = $Count
        Status          = $Status
        Data            = [PSCustomObject]@{
            Computers = $ObsoleteComputers
            Rules     = $ObsoletePatterns
        }
        Recommendations = @(
            "Mettre à niveau les systèmes obsolètes."
        )
        Items           = $ObsoleteComputers
    }
}
