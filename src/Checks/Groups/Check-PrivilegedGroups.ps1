function Test-PrivilegedGroups {
    param(
        [hashtable]$Groups
    )

    $Findings = @()

    foreach ($GroupName in $Groups.Keys) {

        $Members = $Groups[$GroupName]

        if ($Members.Count -gt 0) {

            $Findings += [PSCustomObject]@{
                Id             = "AD-PRIV-001"
                Category       = "PrivilegedGroups"
                Title          = "Membres du groupe $GroupName"
                Severity       = "Critical"
                Risk           = "Les membres de ce groupe disposent de privilèges élevés pouvant compromettre tout le SI."
                Recommendation = "Limiter strictement les membres et privilégier des comptes dédiés."
                Count          = $Members.Count
                Items          = $Members
            }
        }
    }

    return $Findings
}