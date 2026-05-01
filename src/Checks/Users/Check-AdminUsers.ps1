function Test-AdminUsers {
    param(
        [array]$Users,
        [hashtable]$Groups
    )

    $PrivilegedGroups = @(
        "Domain Admins",
        "Enterprise Admins",
        "Administrators"
    )

    $AdminMemberships = foreach ($GroupName in $PrivilegedGroups) {
        foreach ($Member in @($Groups[$GroupName])) {
            if ($Member.SamAccountName) {
                $User = $Users | Where-Object {
                    $_.SamAccountName -eq $Member.SamAccountName
                } | Select-Object -First 1

                [PSCustomObject]@{
                    SamAccountName   = $Member.SamAccountName
                    Name             = if ($User) { $User.Name } else { $Member.Name }
                    Enabled          = if ($User) { $User.Enabled } else { $Member.Enabled }
                    LastLogonDate    = if ($User) { $User.LastLogonDate } else { $Member.LastLogonDate }
                    DistinguishedName = if ($User) { $User.DistinguishedName } else { $Member.DistinguishedName }
                    PrivilegedGroup  = $GroupName
                }
            }
        }
    }

    $AdminUsers = $AdminMemberships |
        Group-Object SamAccountName |
        ForEach-Object {
            $First = $_.Group | Select-Object -First 1

            [PSCustomObject]@{
                SamAccountName   = $First.SamAccountName
                Name             = $First.Name
                Enabled          = $First.Enabled
                LastLogonDate    = $First.LastLogonDate
                DistinguishedName = $First.DistinguishedName
                PrivilegedGroups = ($_.Group.PrivilegedGroup | Sort-Object -Unique) -join ", "
            }
        }

    [PSCustomObject]@{
        Id          = "AD-USR-003"
        Category    = "Users"
        Title       = "Comptes administrateurs détectés"
        Severity    = "High"
        Description = "Comptes utilisateurs appartenant aux groupes administrateurs principaux."
        Count       = ($AdminUsers | Measure-Object).Count
        Data        = $AdminUsers
        Items       = $AdminUsers
    }
}
