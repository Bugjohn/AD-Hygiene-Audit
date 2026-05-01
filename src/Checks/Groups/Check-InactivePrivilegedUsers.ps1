function Test-InactivePrivilegedUsers {
    param(
        [hashtable]$Groups,
        [int]$InactiveDays = 90
    )

    $LimitDate = (Get-Date).AddDays(-$InactiveDays)
    $Findings = @()

    foreach ($GroupName in $Groups.Keys) {

        $Members = $Groups[$GroupName]

        $InactiveMembers = $Members | Where-Object {
            $_.Enabled -eq $true -and (
                $null -eq $_.LastLogonDate -or
                $_.LastLogonDate -lt $LimitDate
            )
        }

        if ($InactiveMembers.Count -gt 0) {

            $Findings += [PSCustomObject]@{
                Id             = "AD-PRIV-002"
                Category       = "PrivilegedGroups"
                Title          = "Comptes inactifs dans $GroupName"
                Severity       = "Critical"
                Risk           = "Un compte inactif avec privilèges élevés peut être compromis sans être détecté."
                Recommendation = "Supprimer ou désactiver immédiatement ces comptes."
                Count          = $InactiveMembers.Count
                Items          = $InactiveMembers
            }
        }
    }

    return $Findings
}