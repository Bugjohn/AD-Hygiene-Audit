function Test-PrivilegedAccountCompliance {
    param(
        [array]$Users,
        [hashtable]$Groups,
        [int]$InactiveDays = 90
    )

    $Findings = @()
    $LimitDate = (Get-Date).AddDays(-$InactiveDays)
    $PrivilegedAccounts = @{}

    if ($Groups) {
        foreach ($GroupName in $Groups.Keys) {
            foreach ($Member in @($Groups[$GroupName])) {
                if (-not [string]::IsNullOrWhiteSpace($Member.SamAccountName)) {
                    $Key = $Member.SamAccountName.ToLowerInvariant()

                    if (-not $PrivilegedAccounts.ContainsKey($Key)) {
                        $PrivilegedAccounts[$Key] = @()
                    }

                    $PrivilegedAccounts[$Key] += $GroupName
                }
            }
        }
    }

    $InactiveAdmins = @($Users | Where-Object {
        $_.AdminCount -eq 1 -and (
            $null -eq $_.LastLogonDate -or
            $_.LastLogonDate -lt $LimitDate
        )
    })

    if ($InactiveAdmins.Count -gt 0) {
        $Findings += [PSCustomObject]@{
            Id             = "AD-PRIV-003"
            Category       = "Privileged"
            Title          = "Comptes administrateurs inactifs"
            Severity       = "High"
            Status         = "NonCompliant"
            Description    = "Comptes avec AdminCount=1 sans activité récente selon le seuil configuré."
            Recommendation = "Vérifier la nécessité de ces comptes, puis les désactiver ou réduire leurs privilèges."
            Count          = $InactiveAdmins.Count
            Items          = $InactiveAdmins
        }
    }

    $ServiceAccountsInPrivilegedGroups = @($Users | Where-Object {
        -not [string]::IsNullOrWhiteSpace(($_.ServicePrincipalName -join "")) -and
        -not [string]::IsNullOrWhiteSpace($_.SamAccountName) -and
        $PrivilegedAccounts.ContainsKey($_.SamAccountName.ToLowerInvariant())
    } | ForEach-Object {
        $Key = $_.SamAccountName.ToLowerInvariant()

        $_ | Select-Object *, @{
            Name       = "PrivilegedGroups"
            Expression = { ($PrivilegedAccounts[$Key] | Sort-Object -Unique) -join ", " }
        }
    })

    if ($ServiceAccountsInPrivilegedGroups.Count -gt 0) {
        $Findings += [PSCustomObject]@{
            Id             = "AD-PRIV-003"
            Category       = "Privileged"
            Title          = "Comptes de service dans les groupes administrateurs"
            Severity       = "High"
            Status         = "NonCompliant"
            Description    = "Comptes avec ServicePrincipalName membres de groupes privilégiés."
            Recommendation = "Retirer ces comptes des groupes administrateurs et appliquer une délégation minimale."
            Count          = $ServiceAccountsInPrivilegedGroups.Count
            Items          = $ServiceAccountsInPrivilegedGroups
        }
    }

    $DisabledAdmins = @($Users | Where-Object {
        $_.AdminCount -eq 1 -and $_.Enabled -eq $false
    })

    if ($DisabledAdmins.Count -gt 0) {
        $Findings += [PSCustomObject]@{
            Id             = "AD-PRIV-003"
            Category       = "Privileged"
            Title          = "Comptes administrateurs désactivés"
            Severity       = "Medium"
            Status         = "NonCompliant"
            Description    = "Comptes désactivés conservant AdminCount=1."
            Recommendation = "Nettoyer les anciens privilèges et vérifier que ces comptes ne sont plus référencés."
            Count          = $DisabledAdmins.Count
            Items          = $DisabledAdmins
        }
    }

    return $Findings
}
