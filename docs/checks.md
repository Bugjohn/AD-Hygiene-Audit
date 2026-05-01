# Checks disponibles

Ce document décrit les checks réellement implémentés et appelés par `src/Core/AuditRunner.ps1` après stabilisation du mode Mock.

---

## Objectif des checks

Chaque check :

- a une responsabilité unique ;
- utilise uniquement les données fournies par les collectors ;
- retourne un ou plusieurs objets `Finding` ;
- peut être filtré par `Mode` et, partiellement, par la configuration JSON.

Le mode Mock couvre l'ensemble des checks listés ci-dessous pour le MVP. Le mode Active Directory réel est préparé dans les collectors, mais il n'est pas encore validé de bout en bout.

## Structure d'un Finding

Structure attendue côté rapports et scoring :

| Champ | Rôle |
| --- | --- |
| `Id` | Identifiant du check, par exemple `AD-USR-001` |
| `Category` | Catégorie logique : `Users`, `Computers`, `Domain`, `PrivilegedGroups`, `Privileged` |
| `Title` | Libellé du finding |
| `Severity` | `Critical`, `High`, `Medium`, `Low` ou `Info` |
| `Status` | Statut de conformité quand le check le renseigne : `Compliant` ou `NonCompliant` |
| `Description` | Description courte du problème ou du contrôle |
| `Risk` | Risque associé quand le check le renseigne |
| `Recommendation` / `Recommendations` | Recommandation simple ou liste de recommandations |
| `Count` | Nombre d'éléments concernés, utilisé par le scoring |
| `Items` | Liste d'objets détaillés, utilisée en priorité par l'export CSV |
| `Data` | Données structurées complémentaires, utilisées pour les synthèses et certains CSV |

Note : les anciens checks ne renseignent pas encore tous `Status` ou `Data`. Le contrat réellement consommé aujourd'hui par le scoring est `Severity` + `Count`, et par les CSV `Items` puis `Data`.

## Modes d'exécution

| Mode | Checks appelés |
| --- | --- |
| `Full` | Users, Computers, Domain, Privileged |
| `Daily` | Identique à `Full` |
| `UsersOnly` | Users uniquement |
| `PrivilegedOnly` | Privileged uniquement |

## Users

### AD-USR-001 — Comptes utilisateurs actifs mais inactifs

- Fonction : `Test-InactiveUsers`
- Appelé en modes : `Full`, `Daily`, `UsersOnly`
- Sévérité : `Medium`
- Paramètre : `InactiveDays`
- Données : `Items`

Identifie les comptes utilisateurs activés dont la dernière connexion est absente ou plus ancienne que le seuil configuré.

### AD-USR-002 — Comptes avec mot de passe qui n'expire jamais

- Fonction : `Test-PasswordNeverExpires`
- Appelé en modes : `Full`, `Daily`, `UsersOnly`
- Sévérité : `High`
- Données : `Items`

Détecte les comptes dont `PasswordNeverExpires` est activé.

### AD-USR-003 — Comptes administrateurs détectés

- Fonction : `Test-AdminUsers`
- Appelé en modes : `Full`, `Daily`, `UsersOnly`
- Sévérité : `High`
- Données : `Items` et `Data`

Identifie les utilisateurs membres des groupes administrateurs principaux : `Domain Admins`, `Enterprise Admins`, `Administrators`.

## Computers

### AD-COMP-001 — Ordinateurs inactifs

- Fonction : `Test-InactiveComputers`
- Appelé en modes : `Full`, `Daily`
- Sévérité : `Medium`
- Paramètre : `InactiveDays`
- Données : `Items` et `Data`

Identifie les comptes ordinateurs dont la dernière connexion est absente ou plus ancienne que le seuil configuré.

### AD-COMP-002 — Systèmes d'exploitation obsolètes

- Fonction : `Test-ObsoleteOperatingSystems`
- Appelé en modes : `Full`, `Daily`
- Sévérité : `High` si non conforme, `Info` si conforme
- Statut : `Compliant` ou `NonCompliant`
- Données : `Items` et `Data`

Détecte les systèmes contenant les motifs suivants : `Windows XP`, `Windows 7`, `Windows Server 2003`, `Windows Server 2008`.

## Domain

### AD-DOM-001 — Password Policy du domaine

- Fonction : `Test-PasswordPolicy`
- Appelé en modes : `Full`, `Daily`
- Sévérité : `Medium` si non conforme, `Info` si conforme
- Statut : `Compliant` ou `NonCompliant`
- Données : `Items` et `Data`

Contrôle la conformité minimale de la stratégie de mot de passe :

- longueur minimale >= 12 ;
- complexité activée ;
- seuil de verrouillage > 0.

### AD-DOM-002 — Password Policy avancée

- Fonction : `Invoke-CheckPasswordPolicyAdvanced`
- Appelé en modes : `Full`, `Daily`
- Sévérité : `High` ou `Medium` selon la règle
- Statut : `NonCompliant`
- Données : `Data`

Génère un finding par écart détecté sur :

- durée maximale du mot de passe > 90 jours ;
- longueur minimale < 12 ;
- historique des mots de passe < 24 ;
- durée de verrouillage < 15 minutes.

### AD-DOM-003 — Kerberos Policy & Exposure

- Fonction : `Test-KerberosPolicyExposure`
- Appelé en modes : `Full`, `Daily`
- Sévérité : `Medium` pour les durées Kerberos, `High` pour les comptes avec SPN
- Statut : `NonCompliant`
- Données : `Data` ou `Items`

Génère un finding par exposition détectée :

- `MaxTicketAge > 10h` ;
- `MaxRenewAge > 7 jours` ;
- `MaxServiceAge > 600 minutes` ;
- comptes utilisateurs avec `ServicePrincipalName`.

## Privileged

### AD-PRIV-001 — Membres des groupes privilégiés

- Fonction : `Test-PrivilegedGroups`
- Appelé en modes : `Full`, `Daily`, `PrivilegedOnly`
- Sévérité : `Critical`
- Données : `Items`

Liste les membres des groupes privilégiés retournés par le collector. En Mock, cela couvre notamment `Domain Admins`, `Enterprise Admins` et `Administrators`.

### AD-PRIV-002 — Comptes inactifs dans groupes privilégiés

- Fonction : `Test-InactivePrivilegedUsers`
- Appelé en modes : `Full`, `Daily`, `PrivilegedOnly`
- Sévérité : `Critical`
- Paramètre : `InactiveDays`
- Données : `Items`

Identifie les comptes inactifs présents dans des groupes privilégiés.

### AD-PRIV-003 — Comptes à privilèges non conformes

- Fonction : `Test-PrivilegedAccountCompliance`
- Appelé en modes : `Full`, `Daily`, `PrivilegedOnly`
- Sévérité : `High` ou `Medium`
- Statut : `NonCompliant`
- Données : `Items`

Génère un finding par type d'écart :

- comptes avec `AdminCount = 1` inactifs ;
- comptes avec SPN membres de groupes privilégiés ;
- comptes désactivés conservant `AdminCount = 1`.

## Checks présents mais non appelés

Certains fichiers de checks existent dans le dépôt mais ne sont pas branchés dans `AuditRunner.ps1` à ce stade. Ils ne font donc pas partie du MVP Mock stabilisé :

- checks Kerberos dédiés hors `AD-DOM-003` ;
- checks de délégation ;
- checks de niveau fonctionnel domaine ;
- checks de lockout policy séparés.

Ils doivent être considérés comme préparatoires tant qu'ils ne sont pas appelés par le runner et couverts par le mode Mock.

## Convention de nommage

Format :

```text
AD-<CAT>-XXX
```

| Catégorie | Description |
| --- | --- |
| `USR` | Utilisateurs |
| `PRIV` | Groupes et comptes privilégiés |
| `COMP` | Ordinateurs |
| `DOM` | Domaine |
