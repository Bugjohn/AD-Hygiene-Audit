# Changelog

All notable changes to the AD-Hygiene-Audit project are documented here.

The format is inspired by "Keep a Changelog" and follows semantic versioning.

---

## [Unreleased]

### Added

- Enriched Mock mode to cover the stabilized MVP across Users, Computers, Domain and Privileged checks.
- Added and stabilized advanced checks:
  - AD-USR-003: administrator user accounts.
  - AD-COMP-001: inactive computer accounts.
  - AD-COMP-002: obsolete operating systems.
  - AD-DOM-001: domain password policy.
  - AD-DOM-002: advanced password policy findings.
  - AD-DOM-003: Kerberos policy exposure and accounts with SPN.
  - AD-PRIV-003: privileged account compliance.
- Added Mock and AD-ready collectors for computers and domain data.
- Added secure Active Directory credential loading through `activeDirectory.credentialFile`.
- Added `ConfigPath` support for JSON-based configuration.

### Changed

- Improved CSV export:
  - one CSV file per finding;
  - safer object flattening;
  - stable file names based on `Id`, `Category` and normalized title.
- Made scoring more robust:
  - numeric score from `0` to `100`;
  - penalties based on `Severity * Count`;
  - invalid or missing `Count` values treated as `0`.
- Made the runner partially configuration-driven:
  - audit defaults can come from config;
  - check families can be enabled or disabled by config;
  - JSON and CSV report exports can be controlled by config.
- Cleaned the example configuration to reflect the current MVP shape.
- Updated technical documentation for checks, scoring and roadmap.

### Known limitations

- Active Directory real mode is prepared but not yet validated end to end.
- HTML and Markdown exports are not available yet.
- Some checks exist as preparatory files but are not wired into `AuditRunner.ps1`.
- Finding fields are not fully uniform across all checks yet.

---

## [1.0.0] - 2026-05-01

### First stable release (MVP)

### Added

- Modular architecture:
  - Collectors
  - Checks
  - Core (`AuditRunner`, `ScoringEngine`)
  - Reports (`JSON`, `CSV`)
- Complete Mock mode for development and validation without Active Directory.
- Data collection:
  - Users (`AD` + Mock)
  - Privileged groups (`AD` + Mock)
- Implemented initial checks:
  - AD-USR-001: inactive user accounts.
  - AD-USR-002: password never expires.
  - AD-PRIV-001: privileged group members.
  - AD-PRIV-002: inactive accounts in privileged groups.
- Numeric global scoring.
- Results export:
  - JSON global overview.
  - CSV file per finding.
- Functional `-Mode` parameter:
  - `Full`
  - `Daily`
  - `UsersOnly`
  - `PrivilegedOnly`

### Fixed

- Fixed a CSV overwrite bug for AD-PRIV-001:
  - one dedicated file is now generated per privileged group.
- Enabled actual check filtering through the `-Mode` parameter.

### Known limitations

- Active Directory collection was partially implemented.
- JSON-based configuration was not fully wired in this release.
- No automated tests yet.
- HTML and Markdown exports were not available.
- Computers, Domain and advanced Privileged checks were planned after the initial MVP release.
