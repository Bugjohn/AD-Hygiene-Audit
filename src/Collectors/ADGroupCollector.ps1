function Get-ADHygienePrivilegedGroups {

    if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
        throw "Module ActiveDirectory introuvable."
    }

    Import-Module ActiveDirectory

    $PrivilegedGroups = @(
        "Domain Admins",
        "Enterprise Admins",
        "Administrators",
        "Schema Admins",
        "Account Operators",
        "Backup Operators",
        "Server Operators",
        "DNS Admins",
        "Group Policy Creator Owners"
    )

    $Result = @{}

    foreach ($GroupName in $PrivilegedGroups) {

        try {
            $Members = Get-ADGroupMember -Identity $GroupName -Recursive | ForEach-Object {

                if ($_.objectClass -eq "user") {

                    $User = Get-ADUser $_.SamAccountName -Properties Enabled, LastLogonDate

                    [PSCustomObject]@{
                        SamAccountName = $User.SamAccountName
                        Name           = $User.Name
                        Enabled        = $User.Enabled
                        LastLogonDate  = $User.LastLogonDate
                        Group          = $GroupName
                    }
                }
            }

            $Result[$GroupName] = $Members
        }
        catch {
            Write-Warning "Impossible de récupérer le groupe $GroupName"
            $Result[$GroupName] = @()
        }
    }

    return $Result
}