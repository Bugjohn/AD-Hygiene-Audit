function Test-PasswordNeverExpires {
    param(
        [array]$Users
    )

    $UsersAtRisk = $Users | Where-Object {
        $_.Enabled -eq $true -and
        $_.PasswordNeverExpires -eq $true
    }

    [PSCustomObject]@{
        Id             = "AD-USR-002"
        Category       = "Users"
        Title          = "Comptes avec mot de passe qui n'expire jamais"
        Severity       = "High"
        Risk           = "Un mot de passe permanent augmente fortement le risque de compromission durable."
        Recommendation = "Limiter aux comptes de service documentés et appliquer une rotation régulière."
        Count          = ($UsersAtRisk | Measure-Object).Count
        Items          = $UsersAtRisk
    }
}