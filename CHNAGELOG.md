# Changelog

Toutes les évolutions notables du projet AD-Hygiene-Audit sont documentées ici.

Le format est inspiré de "Keep a Changelog" et respecte le versioning sémantique.

---

## [1.0.0] - 2026-05-01

### 🎉 Première version stable (MVP)

#### ✅ Ajouté

- Architecture modulaire :
  - Collectors
  - Checks
  - Core (AuditRunner, ScoringEngine)
  - Reports (JSON, CSV)

- Mode Mock complet pour développement sans Active Directory

- Collecte des données :
  - Utilisateurs (AD + Mock)
  - Groupes privilégiés (Mock + structure AD prête)

- Checks implémentés :
  - AD-USR-001 : comptes inactifs
  - AD-USR-002 : password never expires
  - AD-PRIV-001 : membres des groupes privilégiés
  - AD-PRIV-002 : comptes inactifs dans groupes admin

- Scoring global avec niveau de maturité

- Export des résultats :
  - JSON (vue globale)
  - CSV (un fichier par finding)

- Paramètre `-Mode` fonctionnel :
  - Full
  - Daily
  - UsersOnly
  - PrivilegedOnly

---

#### 🛠️ Corrigé

- Correction d’un bug d’écrasement des fichiers CSV pour AD-PRIV-001 :
  - génération d’un fichier unique par groupe privilégié

- Activation réelle du filtrage des checks via le paramètre `-Mode`

---

#### ⚠️ Limites connues

- `ConfigPath` non implémenté
- Tests automatisés absents
- Collecte AD partiellement implémentée
- Exports HTML et Markdown non disponibles
- Plusieurs checks prévus mais non implémentés

---

#### 🚧 À venir

- Ajout des checks :
  - Utilisateurs (admin)
  - Ordinateurs (inactifs, OS obsolètes)
  - Domaine (policies)
  - Kerberos

- Implémentation de la configuration via JSON

- Ajout de tests automatisés

- Export HTML / Markdown

---

## [Unreleased]

- ### Added

- Added AD-USR-003 check to identify administrator user accounts based on privileged group membership.

- Added AD-COMP-001 check to identify inactive computer accounts.
- Added Mock and AD computer collectors.

- Added AD-DOM-001 check to expose the Active Directory password policy.
- Added Mock and AD domain collectors.
