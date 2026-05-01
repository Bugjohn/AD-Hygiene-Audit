. "$PSScriptRoot/../Checks/Users/Check-AdminUsers.ps1"
. "$PSScriptRoot/../Checks/Computers/Check-InactiveComputers.ps1"
. "$PSScriptRoot/../Checks/Computers/Check-ObsoleteOS.ps1"
. "$PSScriptRoot/../Checks/Domain/Check-PasswordPolicy.ps1"
. "$PSScriptRoot/../Checks/Domain/Check-PasswordPolicyAdvanced.ps1"
. "$PSScriptRoot/../Checks/Domain/Check-KerberosPolicyExposure.ps1"
. "$PSScriptRoot/../Checks/Groups/Check-PrivilegedAccountCompliance.ps1"

. "$PSScriptRoot/../Collectors/MockComputerCollector.ps1"
. "$PSScriptRoot/../Collectors/ADComputerCollector.ps1"
. "$PSScriptRoot/../Collectors/MockDomainCollector.ps1"
. "$PSScriptRoot/../Collectors/ADDomainCollector.ps1"

function Invoke-AuditRunner {
    param(
        [string]$OutputPath,
        [int]$InactiveDays,
        [string]$Mode,
        [switch]$UseMockData,
        [object]$Config
    )

    Write-Host "=== AD Hygiene Audit ===" -ForegroundColor Cyan
    Write-Host "Mode : $Mode"
    Write-Host "Seuil inactivité : $InactiveDays jours"
    Write-Host "Mock mode : $UseMockData"
    Write-Host ""

    $Findings = @()
    $Groups = $null
    $Users = $null

    function Test-ConfigFlagEnabled {
        param(
            [object]$Section,
            [string]$Name
        )

        if ($null -eq $Section) {
            return $true
        }

        $Property = $Section.PSObject.Properties[$Name]

        if ($null -eq $Property -or $null -eq $Property.Value) {
            return $true
        }

        return [bool]$Property.Value
    }

    $ChecksConfig = $Config.checks
    $ReportsConfig = $Config.reports

    $RunInactiveUsersCheck = Test-ConfigFlagEnabled -Section $ChecksConfig.users -Name "inactiveUsers"
    $RunPasswordNeverExpiresCheck = Test-ConfigFlagEnabled -Section $ChecksConfig.users -Name "passwordNeverExpires"
    $RunAdminUsersCheck = Test-ConfigFlagEnabled -Section $ChecksConfig.users -Name "adminUsers"

    $RunPrivilegedGroupMembersCheck = Test-ConfigFlagEnabled -Section $ChecksConfig.privilegedGroups -Name "members"
    $RunInactivePrivilegedMembersCheck = Test-ConfigFlagEnabled -Section $ChecksConfig.privilegedGroups -Name "inactiveMembers"
    $RunPrivilegedAccountComplianceCheck = Test-ConfigFlagEnabled -Section $ChecksConfig.privilegedGroups -Name "accountCompliance"

    $RunInactiveComputersCheck = Test-ConfigFlagEnabled -Section $ChecksConfig.computers -Name "inactiveComputers"
    $RunObsoleteOperatingSystemsCheck = Test-ConfigFlagEnabled -Section $ChecksConfig.computers -Name "obsoleteOperatingSystems"

    $RunPasswordPolicyCheck = Test-ConfigFlagEnabled -Section $ChecksConfig.domain -Name "passwordPolicy"
    $RunPasswordPolicyAdvancedCheck = Test-ConfigFlagEnabled -Section $ChecksConfig.domain -Name "passwordPolicyAdvanced"
    $RunKerberosPolicyExposureCheck = Test-ConfigFlagEnabled -Section $ChecksConfig.domain -Name "kerberosPolicyExposure"

    $ExportJsonReport = Test-ConfigFlagEnabled -Section $ReportsConfig -Name "json"
    $ExportCsvReport = Test-ConfigFlagEnabled -Section $ReportsConfig -Name "csv"

    $RunUserChecks = ($Mode -in @("Full", "Daily", "UsersOnly")) -and (
        $RunInactiveUsersCheck -or
        $RunPasswordNeverExpiresCheck -or
        $RunAdminUsersCheck
    )
    $RunPrivilegedChecks = ($Mode -in @("Full", "Daily", "PrivilegedOnly")) -and (
        $RunPrivilegedGroupMembersCheck -or
        $RunInactivePrivilegedMembersCheck -or
        $RunPrivilegedAccountComplianceCheck
    )
    $RunComputerChecks = ($Mode -in @("Full", "Daily")) -and (
        $RunInactiveComputersCheck -or
        $RunObsoleteOperatingSystemsCheck
    )
    $RunDomainChecks = ($Mode -in @("Full", "Daily")) -and (
        $RunPasswordPolicyCheck -or
        $RunPasswordPolicyAdvancedCheck -or
        $RunKerberosPolicyExposureCheck
    )

    # ---------------------------
    # USERS
    # ---------------------------
    if ($RunUserChecks) {
        Write-Host "[1/7] Collecte des utilisateurs..."

        if ($UseMockData) {
            $Users = Get-MockUsers
        } else {
            $Users = Get-ADHygieneUsers
        }

        if ($RunInactiveUsersCheck) {
            Write-Host "[2/7] Analyse des comptes inactifs..."
            $Findings += Test-InactiveUsers `
                -Users $Users `
                -InactiveDays $InactiveDays
        }

        if ($RunPasswordNeverExpiresCheck) {
            Write-Host "[3/7] Analyse PasswordNeverExpires..."
            $Findings += Test-PasswordNeverExpires -Users $Users
        }

        if ($RunAdminUsersCheck) {
            Write-Host "[4/7] Analyse des comptes administrateurs..."

            if ($null -eq $Groups) {
                if ($UseMockData) {
                    $Groups = Get-MockPrivilegedGroups
                } else {
                    $Groups = Get-ADHygienePrivilegedGroups
                }
            }

            $Findings += Test-AdminUsers `
                -Users $Users `
                -Groups $Groups
        }
    }

    # ---------------------------
    # COMPUTERS
    # ---------------------------
    if ($RunComputerChecks) {
        Write-Host "[5/7] Analyse des ordinateurs inactifs..."

        if ($UseMockData) {
            $Computers = Get-MockComputers
        } elseif (Get-Command Get-ADHygieneComputers -ErrorAction SilentlyContinue) {
            $Computers = Get-ADHygieneComputers
        } else {
            Write-Warning "Collecteur ordinateurs indisponible. Le check AD-COMP-001 est ignoré."
            $Computers = @()
        }

        if ($RunInactiveComputersCheck) {
            $Findings += Test-InactiveComputers `
                -Computers $Computers `
                -InactiveDays $InactiveDays
        }

        if ($RunObsoleteOperatingSystemsCheck) {
            Write-Host "[5/7] Analyse des systèmes d'exploitation obsolètes..."
            $Findings += Test-ObsoleteOperatingSystems -Computers $Computers
        }
    }

    # ---------------------------
    # DOMAIN
    # ---------------------------
    if ($RunDomainChecks) {
        Write-Host "[5/7] Lecture de la Password Policy..."

        if ($UseMockData) {
            $Policy = Get-MockPasswordPolicy
        } elseif (Get-Command Get-ADHygienePasswordPolicy -ErrorAction SilentlyContinue) {
            $Policy = Get-ADHygienePasswordPolicy
        } else {
            Write-Warning "Collecteur domain indisponible"
            $Policy = $null
        }

        if ($Policy) {
            if ($RunPasswordPolicyCheck) {
                $Findings += Test-PasswordPolicy -Policy $Policy
            }

            if ($RunPasswordPolicyAdvancedCheck) {
                $Findings += Invoke-CheckPasswordPolicyAdvanced -Domain $Policy
            }

            if ($RunKerberosPolicyExposureCheck) {
                if ($null -eq $Users) {
                    if ($UseMockData) {
                        $Users = Get-MockUsers
                    } else {
                        $Users = Get-ADHygieneUsers
                    }
                }

                $Findings += Test-KerberosPolicyExposure `
                    -Domain $Policy `
                    -Users $Users
            }
        }
    }

    # ---------------------------
    # PRIVILEGED
    # ---------------------------
    if ($RunPrivilegedChecks) {
        Write-Host "[4/7] Analyse des groupes privilégiés..."

        if ($null -eq $Groups) {
            if ($UseMockData) {
                $Groups = Get-MockPrivilegedGroups
            } else {
                $Groups = Get-ADHygienePrivilegedGroups
            }
        }

        if ($null -eq $Users) {
            if ($UseMockData) {
                $Users = Get-MockUsers
            } else {
                $Users = Get-ADHygieneUsers
            }
        }

        if ($RunPrivilegedGroupMembersCheck) {
            $Findings += Test-PrivilegedGroups -Groups $Groups
        }

        if ($RunInactivePrivilegedMembersCheck) {
            Write-Host "[5/7] Analyse des comptes inactifs dans groupes privilégiés..."

            $Findings += Test-InactivePrivilegedUsers `
                -Groups $Groups `
                -InactiveDays $InactiveDays
        }

        if ($RunPrivilegedAccountComplianceCheck) {
            $Findings += Test-PrivilegedAccountCompliance `
                -Users $Users `
                -Groups $Groups `
                -InactiveDays $InactiveDays
        }
    }

    # ---------------------------
    # SCORE
    # ---------------------------
    Write-Host "[6/7] Calcul du score global..."
    $ScoreSummary = Get-ADHygieneScore -Findings $Findings

    Write-Host "Score global : $($ScoreSummary.Score)/100" -ForegroundColor Yellow

    # ---------------------------
    # REPORTS
    # ---------------------------
    Write-Host "[7/7] Export des rapports..."
    if ($ExportJsonReport) {
        Export-ADHygieneJsonReport `
            -Findings $Findings `
            -ScoreSummary $ScoreSummary `
            -OutputPath $OutputPath
    }

    if ($ExportCsvReport) {
        Export-ADHygieneCsvReport `
            -Findings $Findings `
            -OutputPath $OutputPath
    }
}
