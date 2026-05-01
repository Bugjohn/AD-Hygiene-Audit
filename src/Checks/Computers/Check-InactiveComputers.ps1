function Test-InactiveComputers {
    param(
        [array]$Computers,
        [int]$InactiveDays = 90
    )

    $LimitDate = (Get-Date).AddDays(-$InactiveDays)

    $InactiveComputers = $Computers | Where-Object {
        $null -eq $_.LastLogonDate -or
        $_.LastLogonDate -lt $LimitDate
    }

    [PSCustomObject]@{
        Id          = "AD-COMP-001"
        Category    = "Computers"
        Title       = "Ordinateurs inactifs"
        Severity    = "Medium"
        Description = "Ordinateurs dont la dernière connexion dépasse le seuil d'inactivité défini."
        Count       = ($InactiveComputers | Measure-Object).Count
        Data        = $InactiveComputers
        Items       = $InactiveComputers
    }
}
