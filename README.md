# AD-Hygiene-Audit

Outil PowerShell d'audit d'hygiene Active Directory niveau 1, concu avec une architecture modulaire, robuste et exploitable en entreprise.

🌍 Languages: [🇬🇧 English](README.en-us.md) | 🇫🇷 French (default)

---

## Objectif

Identifier rapidement les faiblesses classiques d'un Active Directory :

- comptes inactifs ;
- mots de passe non conformes ;
- exposition des comptes privilegies ;
- configuration domaine a risque.

Le MVP actuel est complet et valide en mode Mock. Le mode Active Directory reel est prepare dans les collecteurs, mais il n'est pas encore valide de bout en bout sur un environnement AD reel.

## Quick Start

### 1. Cloner le projet

```powershell
git clone https://github.com/Bugjohn/AD-Hygiene-Audit.git
cd AD-Hygiene-Audit
```

### 2. Tester immediatement le MVP en mode Mock

Aucun prerequis AD n'est necessaire.

```powershell
pwsh -File ./Invoke-ADHygieneAudit.ps1 `
  -UseMockData `
  -OutputPath ./outputs `
  -InactiveDays 90 `
  -Mode Full
```

Resultat : un audit Mock complet pour le MVP est genere dans `outputs/`.

### 3. Lire les resultats

```text
outputs/
├── ad-hygiene-report.json
├── AD-USR-001-Users-Comptes_utilisateurs_actifs_mais_inactifs.csv
├── AD-USR-002-Users-Comptes_avec_mot_de_passe_qui_n'expire_jamais.csv
├── AD-PRIV-001-PrivilegedGroups-Domain_Admins.csv
```

Les exports disponibles aujourd'hui sont JSON et CSV. Les exports HTML et Markdown sont prevus mais ne sont pas encore disponibles.

## Connexion a un Active Directory reel

### Statut MVP

Le chemin AD reel est prepare, mais non valide pour ce MVP. Utiliser d'abord le mode Mock comme reference fonctionnelle.

### Prerequis

- PowerShell 7+
- RSAT / module PowerShell `ActiveDirectory`
- acces reseau a l'AD
- fichier de configuration contenant `activeDirectory.credentialFile`

### Creer un fichier de credentials securise

Le chemin du credential n'est pas un parametre CLI. Il doit etre declare dans la configuration, via `activeDirectory.credentialFile`.

```powershell
Get-Credential | Export-Clixml -Path ./config/ad-credential.xml
```

### Lancer avec une configuration

`ConfigPath` est disponible pour pointer vers un fichier de configuration.

```powershell
pwsh -File ./Invoke-ADHygieneAudit.ps1 `
  -ConfigPath ./config/audit-config.example.json `
  -OutputPath ./outputs-ad `
  -InactiveDays 90 `
  -Mode Full
```

Le mode Mock est active uniquement avec `-UseMockData`. Sans `-UseMockData`, l'outil utilise les collecteurs AD reels et la configuration fournie.

## QuickStart detaille

Un guide pas-a-pas est disponible ici :

[docs/QuickStart.md](docs/QuickStart.md)

## Architecture

Le projet est structure en modules :

- `Collectors` : source unique de donnees, Mock ou AD.
- `Checks` : regles d'audit independantes.
- `Core` : orchestration avec `AuditRunner` et `ScoringEngine`.
- `Reports` : exports JSON et CSV.

Regles fondamentales :

- les collecteurs sont la seule source de donnees ;
- les checks ne doivent jamais interroger l'AD directement ;
- le mode Mock doit toujours fonctionner.

## Modes d'execution

| Mode             | Description                            |
| ---------------- | -------------------------------------- |
| `Full`           | Tous les checks disponibles            |
| `Daily`          | Identique a `Full`, pour planification |
| `UsersOnly`      | Checks utilisateurs uniquement         |
| `PrivilegedOnly` | Checks privilegies uniquement          |

## Resultats

- JSON : `ad-hygiene-report.json`, vue globale, synthese et scoring.
- CSV : un fichier par finding exploitable dans Excel, LibreOffice ou un SIEM.

Convention CSV actuelle :

```text
<Id>-<Category>-<Titre_normalise>.csv
```

Exemples :

```text
AD-USR-001-Users-Comptes_utilisateurs_actifs_mais_inactifs.csv
AD-COMP-001-Computers-Ordinateurs_inactifs.csv
AD-PRIV-001-PrivilegedGroups-Administrators.csv
```

## Scoring

Le score reel est numerique, de `0` a `100`.

La base est `100`, puis les penalites sont appliquees selon la severite et le nombre d'elements detectes :

| Severite   | Penalite par element |
| ---------- | -------------------: |
| `Critical` |                   20 |
| `High`     |                   10 |
| `Medium`   |                    5 |
| `Low`      |                    2 |
| `Info`     |                    0 |

Le rapport expose aussi le nombre de findings par severite.

## Mode Mock

Le mode Mock permet de :

- tester le MVP complet sans AD ;
- developper de nouveaux checks ;
- valider les exports JSON et CSV.

Activation :

```powershell
pwsh -File ./Invoke-ADHygieneAudit.ps1 -UseMockData
```

## Ajouter un check

Etapes :

1. Creer un fichier dans `src/Checks/<Category>/`.
2. Respecter le format de sortie `Finding`.
3. Ajouter le check dans `src/Core/AuditRunner.ps1`.

Contraintes :

- un check = une responsabilite ;
- aucun appel direct a l'AD ;
- utiliser uniquement les donnees des collecteurs.

## Checks disponibles

Voir [docs/checks.md](docs/checks.md).

## Roadmap

- Validation du mode AD reel.
- Checks avances : AD Tiering, ACL, GPO.
- Exports HTML / Markdown.
- Tests automatises.
- Integration CI/CD.

## Avertissement

Cet outil fournit un audit de premier niveau.

Il ne remplace pas :

- un audit de securite complet ;
- une revue d'architecture AD ;
- un audit Red Team / Pentest.

## Contribution

Les contributions sont les bienvenues :

- nouveaux checks ;
- amelioration des exports ;
- optimisation des performances.

## Support

Projet interne / experimental. Adapter selon votre contexte entreprise.
