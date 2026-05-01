function Test-InactiveUsers {
    param(
        [array]$Users,
        [int]$InactiveDays = 90
    )

    $LimitDate = (Get-Date).AddDays(-$InactiveDays)

    $InactiveUsers = $Users | Where-Object {
        $_.Enabled -eq $true -and (
            $null -eq $_.LastLogonDate -or
            $_.LastLogonDate -lt $LimitDate
        )
    }

    [PSCustomObject]@{
        Id             = "AD-USR-001"
        Category       = "Users"
        Title          = "Comptes utilisateurs actifs mais inactifs"
        Severity       = "Medium"
        Risk           = "Des comptes dormants peuvent être utilisés par un attaquant s’ils sont compromis."
        Recommendation = "Désactiver, supprimer ou justifier les comptes inactifs."
        Count          = ($InactiveUsers | Measure-Object).Count
        Items          = $InactiveUsers
    }
}