function Get-ADHygienePrivilegedGroups {

    if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
        throw "Module ActiveDirectory introuvable."
    }

    Import-Module ActiveDirectory
    $CredentialFile = $Config.activeDirectory.credentialFile

    if ([string]::IsNullOrWhiteSpace($CredentialFile)) {
        throw "Aucun fichier de credential Active Directory n'est configuré (activeDirectory.credentialFile)."
    }

    if (-not (Test-Path -Path $CredentialFile)) {
        throw "Fichier de credential Active Directory introuvable : $CredentialFile"
    }

    $Credential = Import-Clixml -Path $CredentialFile

    if ($null -eq $Credential -or -not ($Credential -is [System.Management.Automation.PSCredential]) -or [string]::IsNullOrWhiteSpace($Credential.UserName)) {
        throw "Impossible de charger le credential depuis $CredentialFile"
    }

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
            $Members = Get-ADGroupMember -Identity $GroupName -Recursive -Credential $Credential | ForEach-Object {

                if ($_.objectClass -eq "user") {

                    $User = Get-ADUser $_.SamAccountName -Credential $Credential -Properties Enabled, LastLogonDate

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
