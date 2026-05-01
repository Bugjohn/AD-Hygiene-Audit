# QuickStart — AD-Hygiene-Audit

Guide de demarrage rapide pour lancer un audit d'hygiene Active Directory avec **AD-Hygiene-Audit**.

Ce guide couvre le MVP actuel : le mode Mock est complet et valide, tandis que le mode Active Directory reel est prepare mais pas encore valide de bout en bout sur un environnement AD reel.

---

## 1. Objectif

Ce guide explique comment :

1. preparer l'environnement ;
2. lancer un premier audit en mode Mock ;
3. recuperer les rapports generes ;
4. preparer une configuration pour l'AD reel ;
5. comprendre le statut actuel des exports et du scoring.

## 2. Prerequis

### 2.1 PowerShell

L'outil necessite PowerShell 7 ou superieur.

```powershell
pwsh --version
```

Exemple attendu :

```text
PowerShell 7.x.x
```

### 2.2 Module Active Directory

Le mode Mock ne necessite pas Active Directory.

Pour le mode AD reel, le module PowerShell `ActiveDirectory` doit etre disponible :

```powershell
Get-Module -ListAvailable ActiveDirectory
```

Sur Windows, installer RSAT si le module est absent :

```powershell
Get-WindowsCapability -Name RSAT.ActiveDirectory* -Online
Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
```

### 2.3 Droits necessaires

Le compte utilise pour l'audit AD reel doit pouvoir lire l'annuaire Active Directory. Un compte de lecture standard suffit generalement pour lire les utilisateurs, ordinateurs, groupes et politiques du domaine.

## 3. Recuperer le projet

```powershell
git clone https://github.com/<user>/AD-Hygiene-Audit.git
cd AD-Hygiene-Audit
```

Verifier que le fichier principal est present :

```powershell
Get-ChildItem
```

Vous devez voir notamment :

```text
Invoke-ADHygieneAudit.ps1
src/
docs/
```

## 4. Premier test en mode Mock

Le mode Mock permet de tester le MVP complet sans Active Directory. C'est le mode recommande pour verifier que l'outil fonctionne.

```powershell
pwsh -File ./Invoke-ADHygieneAudit.ps1 `
  -UseMockData `
  -OutputPath ./outputs `
  -InactiveDays 90 `
  -Mode Full
```

Parametres principaux :

| Parametre | Role |
| --- | --- |
| `-UseMockData` | Utilise les donnees de test du MVP |
| `-OutputPath ./outputs` | Dossier ou seront generes les rapports |
| `-InactiveDays 90` | Seuil d'inactivite en jours |
| `-Mode Full` | Lance tous les checks disponibles |
| `-ConfigPath ./config/audit-config.example.json` | Charge une configuration explicite |

## 5. Verifier les resultats Mock

```powershell
Get-ChildItem ./outputs
```

Vous devez obtenir des fichiers de rapport, par exemple :

```text
ad-hygiene-report.json
AD-USR-001-Users-Comptes_utilisateurs_actifs_mais_inactifs.csv
AD-USR-002-Users-Comptes_avec_mot_de_passe_qui_n'expire_jamais.csv
AD-COMP-001-Computers-Ordinateurs_inactifs.csv
AD-PRIV-001-PrivilegedGroups-Administrators.csv
AD-PRIV-001-PrivilegedGroups-Domain_Admins.csv
```

La convention actuelle des CSV est :

```text
<Id>-<Category>-<Titre_normalise>.csv
```

Si `ad-hygiene-report.json` existe et que des CSV sont generes, le MVP Mock fonctionne correctement.

## 6. Lire les resultats

Lister les fichiers :

```powershell
Get-ChildItem ./outputs
```

Ouvrir le rapport JSON :

```powershell
Get-Content ./outputs/ad-hygiene-report.json
```

Ouvrir les fichiers CSV dans Excel ou LibreOffice. Les CSV correspondent aux findings detectes par check.

Les exports actuellement disponibles sont :

- JSON : `ad-hygiene-report.json`
- CSV : un fichier par finding avec donnees exportables

Les exports HTML et Markdown ne sont pas encore disponibles.

## 7. Scoring

Le scoring reel est numerique, de `0` a `100`.

La base est `100`, puis des penalites sont appliquees selon la severite et le nombre d'elements detectes :

| Severite | Penalite par element |
| --- | ---: |
| `Critical` | 20 |
| `High` | 10 |
| `Medium` | 5 |
| `Low` | 2 |
| `Info` | 0 |

Le JSON contient aussi un resume par severite : `Critical`, `High`, `Medium`, `Low`, `Info`.

## 8. Utiliser ConfigPath

`ConfigPath` permet de charger explicitement un fichier de configuration.

```powershell
pwsh -File ./Invoke-ADHygieneAudit.ps1 `
  -ConfigPath ./config/audit-config.example.json `
  -UseMockData `
  -OutputPath ./outputs-config
```

Les parametres passes en ligne de commande restent prioritaires sur les valeurs de configuration.

## 9. Preparer l'AD reel

Le mode AD reel est prepare dans le code, mais il n'est pas encore valide pour ce MVP. Pour une execution AD reelle, le chemin du credential doit etre defini dans la configuration avec `activeDirectory.credentialFile`.

Creer le credential au chemin attendu par la configuration d'exemple :

```powershell
Get-Credential | Export-Clixml -Path ./config/ad-credential.xml
```

Ce fichier :

- ne doit pas etre partage ;
- ne fonctionne que pour l'utilisateur Windows qui l'a cree ;
- ne doit pas etre commite dans Git.

Verifier le fichier :

```powershell
Test-Path ./config/ad-credential.xml
```

Resultat attendu :

```text
True
```

Lancer l'audit en utilisant une configuration :

```powershell
pwsh -File ./Invoke-ADHygieneAudit.ps1 `
  -ConfigPath ./config/audit-config.example.json `
  -OutputPath ./outputs-ad `
  -InactiveDays 90 `
  -Mode Full
```

Important : le mode Mock est active uniquement si la commande contient `-UseMockData`. Sans `-UseMockData`, l'outil utilise les collecteurs AD reels et la configuration fournie.

## 10. Modes disponibles

| Mode | Description |
| --- | --- |
| `Full` | Lance tous les checks disponibles |
| `Daily` | Mode prevu pour execution planifiee |
| `UsersOnly` | Lance uniquement les checks utilisateurs |
| `PrivilegedOnly` | Lance uniquement les checks lies aux privileges |

Exemple utilisateurs uniquement en Mock :

```powershell
pwsh -File ./Invoke-ADHygieneAudit.ps1 `
  -UseMockData `
  -OutputPath ./outputs-users `
  -InactiveDays 90 `
  -Mode UsersOnly
```

## 11. Erreurs frequentes

### Le module ActiveDirectory est introuvable

Erreur probable :

```text
The specified module 'ActiveDirectory' was not loaded
```

Solution : installer RSAT Active Directory. Cette erreur ne concerne pas le mode Mock.

### Le fichier credential AD est introuvable

Erreur probable :

```text
Fichier de credential Active Directory introuvable
```

Solution : verifier le chemin configure dans `activeDirectory.credentialFile`.

```powershell
Test-Path ./config/ad-credential.xml
```

### Mauvais identifiant ou mot de passe

Solution : regenerer le fichier de credential au chemin configure.

```powershell
Get-Credential | Export-Clixml -Path ./config/ad-credential.xml
```

### Aucun resultat dans certains CSV

Ce n'est pas forcement une erreur. Cela peut signifier que le check n'a detecte aucun probleme.

Exemples :

- aucun compte inactif ;
- aucun OS obsolete ;
- aucun compte privilegie non conforme.

## 12. Bonnes pratiques

Ne jamais commiter les credentials.

Ajouter dans `.gitignore` si necessaire :

```gitignore
*.xml
*credential*
_cred_
```

Utiliser idealement un compte AD dedie, par exemple `audit.ad`, avec uniquement les droits necessaires en lecture.

Separer les sorties Mock et AD reel :

```text
outputs-mock/
outputs-ad/
```

## 13. Exemple complet recommande

Test Mock :

```powershell
pwsh -File ./Invoke-ADHygieneAudit.ps1 `
  -UseMockData `
  -OutputPath ./outputs-mock `
  -InactiveDays 90 `
  -Mode Full
```

Preparation AD reelle :

```powershell
Get-Credential | Export-Clixml -Path ./config/ad-credential.xml
```

Execution AD reelle preparee, non validee pour le MVP :

```powershell
pwsh -File ./Invoke-ADHygieneAudit.ps1 `
  -ConfigPath ./config/audit-config.example.json `
  -OutputPath ./outputs-ad `
  -InactiveDays 90 `
  -Mode Full
```

## 14. Rappel important

AD-Hygiene-Audit est un outil d'audit de premier niveau. Il permet d'identifier rapidement des faiblesses d'hygiene Active Directory.

Il ne remplace pas :

- un audit de securite complet ;
- une revue d'architecture AD ;
- un audit Red Team / Pentest.
