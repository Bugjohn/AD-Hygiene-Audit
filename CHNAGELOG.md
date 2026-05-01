# Changelog

All notable changes to the AD-Hygiene-Audit project are documented here.

The format is inspired by "Keep a Changelog" and follows semantic versioning.

---

## [1.0.0] - 2026-05-01

### 🎉 First stable release (MVP)

#### ✅ Added

- Modular architecture:
  - Collectors
  - Checks
  - Core (AuditRunner, ScoringEngine)
  - Reports (JSON, CSV)

- Complete Mock mode for development without Active Directory

- Data collection:
  - Users (AD + Mock)
  - Privileged groups (Mock + AD-ready structure)

- Implemented checks:
  - AD-USR-001: inactive accounts
  - AD-USR-002: password never expires
  - AD-PRIV-001: privileged group members
  - AD-PRIV-002: inactive accounts in admin groups

- Global scoring with maturity level

- Results export:
  - JSON (global overview)
  - CSV (one file per finding)

- Functional `-Mode` parameter:
  - Full
  - Daily
  - UsersOnly
  - PrivilegedOnly

---

#### 🛠️ Fixed

- Fixed a CSV overwrite bug for AD-PRIV-001:
  - one dedicated file is now generated per privileged group

- Enabled actual check filtering through the `-Mode` parameter

---

#### ⚠️ Known limitations

- `ConfigPath` not implemented
- No automated tests yet
- AD collection partially implemented
- HTML and Markdown exports not available
- Several planned checks not yet implemented

---

#### 🚧 Coming next

- Add checks for:
  - Users (admin accounts)
  - Computers (inactive, obsolete OS)
  - Domain (policies)
  - Kerberos

- Implement JSON-based configuration

- Add automated tests

- Add HTML / Markdown exports

---

## [Unreleased]

### Added

- Added AD-USR-003 check to identify administrator user accounts based on privileged group membership.

- Added AD-COMP-001 check to identify inactive computer accounts.
- Added Mock and AD computer collectors.

- Added AD-DOM-001 check to expose the Active Directory password policy.
- Added Mock and AD domain collectors.
- Improved AD-DOM-001 to analyze password policy compliance instead of only exposing raw values.

- Added AD-COMP-002 check to detect obsolete operating systems.

- Added secure Active Directory credential loading from `activeDirectory.credentialFile` using `Import-Clixml`.
- Added AD-PRIV-003 check to identify non-compliant privileged accounts.
- Added AD-DOM-003 check to analyze Kerberos policy exposure and accounts with SPN.

- Updated checks documentation with AD-PRIV-003 and AD-DOM-003.
