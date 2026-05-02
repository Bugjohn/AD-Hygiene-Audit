# AD-Hygiene-Audit

PowerShell tool for Level 1 Active Directory hygiene auditing, designed with a modular, robust architecture suitable for enterprise use.

🌍 Languages: [🇬🇧 English](README.en-us.md) | [🇫🇷 Français](README.md)

---

## Objective

Quickly identify common weaknesses in an Active Directory:

- inactive accounts;
- non-compliant passwords;
- privileged account exposure;
- risky domain configurations.

The current MVP is complete and validated in Mock mode.  
The real Active Directory mode is prepared in the collectors, but has not yet been fully validated end-to-end on a real AD environment.

## Quick Start

### 1. Clone the project

```powershell
git clone https://github.com/<user>/AD-Hygiene-Audit.git
cd AD-Hygiene-Audit
```

### 2. Instantly test the MVP in Mock mode

No Active Directory prerequisites required.

pwsh -File ./Invoke-ADHygieneAudit.ps1 `  -UseMockData`
-OutputPath ./outputs `  -InactiveDays 90`
-Mode Full

Result: a complete Mock audit for the MVP is generated in outputs/.

### 3. Review results

outputs/
├── ad-hygiene-report.json
├── AD-USR-001-Users-Active_users_but_inactive.csv
├── AD-USR-002-Users-Password_never_expires.csv
├── AD-PRIV-001-PrivilegedGroups-Domain_Admins.csv

Available exports today: JSON and CSV.
HTML and Markdown exports are planned but not yet available.
Connecting to a real Active Directory
MVP Status
The real AD path is prepared but not validated for this MVP.
Use Mock mode first as a functional reference.

### Prerequisites

PowerShell 7+
RSAT / PowerShell ActiveDirectory module
network access to AD
configuration file containing activeDirectory.credentialFile

### Create a secure credential file

The credential path is not a CLI parameter.
It must be defined in the configuration via activeDirectory.credentialFile.
Get-Credential | Export-Clixml -Path ./config/ad-credential.xml
Run with a configuration
ConfigPath allows you to specify a configuration file.

pwsh -File ./Invoke-ADHygieneAudit.ps1 `  -ConfigPath ./config/audit-config.example.json`
-OutputPath ./outputs-ad `  -InactiveDays 90`
-Mode Full

Mock mode is only enabled with -UseMockData.
Without -UseMockData, the tool uses real AD collectors and the provided configuration.

### Detailed Quick Start

A step-by-step guide is available here:
docs/QuickStart.md

### Architecture

The project is structured into modules:
Collectors: single source of data, Mock or AD
Checks: independent audit rules
Core: orchestration with AuditRunner and ScoringEngine
Reports: JSON and CSV exports

### Core principles:

collectors are the only data source;
checks must never query AD directly;
Mock mode must always work.

### Execution Modes

Mode Description
Full All available checks
Daily Same as Full, intended for scheduling
UsersOnly User-related checks only
PrivilegedOnly Privileged checks only

### Results

JSON: ad-hygiene-report.json, global view, summary, and scoring
CSV: one file per finding, usable in Excel, LibreOffice, or a SIEM
Current CSV naming convention:
<Id>-<Category>-<Normalized_title>.csv

Examples:
AD-USR-001-Users-Active_users_but_inactive.csv
AD-COMP-001-Computers-Inactive_computers.csv
AD-PRIV-001-PrivilegedGroups-Administrators.csv

Scoring

The actual score is numeric, from 0 to 100.
Base score is 100, then penalties are applied based on severity and number of findings:

Severity Penalty per item
Critical 20
High 10
Medium 5
Low 2
Info 0

The report also includes the number of findings per severity.

### Mock Mode

Mock mode allows you to:
test the full MVP without AD;
develop new checks;
validate JSON and CSV exports.

Activation:
pwsh -File ./Invoke-ADHygieneAudit.ps1 -UseMockData

### Adding a Check

Steps:
Create a file in src/Checks/<Category>/
Follow the Finding output format
Register the check in src/Core/AuditRunner.ps1

Constraints:

one check = one responsibility;
no direct AD calls;
use only collector data.
Available Checks
See docs/checks.md.

### Roadmap

Validation of real AD mode
Advanced checks: AD Tiering, ACLs, GPOs
HTML / Markdown exports
Automated testing
CI/CD integration

### Disclaimer

This tool provides a first-level audit.

It does not replace:
a full security audit;
an AD architecture review;
a Red Team / Pentest assessment.

### Contribution

Contributions are welcome:
new checks;
export improvements;
performance optimizations.

### Support

Internal / experimental project.
Adapt to your organization’s context.
