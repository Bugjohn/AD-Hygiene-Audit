# AD-Hygiene-Audit

Outil PowerShell d’audit d’hygiène Active Directory (niveau 1 sécurité), conçu avec une architecture modulaire et extensible.

## 🎯 Objectif

Identifier rapidement les faiblesses de base d’un Active Directory :

- comptes inactifs
- mauvaises pratiques sur les mots de passe
- exposition des comptes privilégiés

L’outil est conçu pour être :

- simple à exécuter
- lisible dans ses résultats
- extensible par ajout de checks

---

## 🏗️ Architecture

Le projet est structuré en modules :

- **Collectors** : récupération des données (AD ou Mock)
- **Checks** : règles d’audit indépendantes
- **Core** : orchestration (AuditRunner, Scoring)
- **Reports** : export des résultats (JSON, CSV)
- **Utils** : fonctions utilitaires (à venir)

⚠️ Règle clé :

> Les Collectors sont la source unique de données.  
> Les Checks ne doivent jamais interroger directement l’AD.

---

## 🚀 Installation

### Prérequis

- PowerShell 7+
- Accès Active Directory (si mode réel)
- Module ActiveDirectory (RSAT) pour le mode AD

### Cloner le projet

```bash
git clone https://github.com/<user>/AD-Hygiene-Audit.git
cd AD-Hygiene-Audit
```

▶️ Utilisation
Mode Mock (recommandé pour test)
pwsh -File ./Invoke-ADHygieneAudit.ps1 `  -UseMockData`
-OutputPath ./outputs `  -InactiveDays 90`
-Mode Full
Modes disponibles
Mode Description
Full Tous les checks
Daily Identique à Full (prévu pour planification)
UsersOnly Checks utilisateurs uniquement
PrivilegedOnly Checks groupes privilégiés uniquement

📊 Résultats
Les rapports sont générés dans le dossier outputs/ :
JSON : vue globale + scoring
CSV : un fichier par finding
Exemple :
outputs/
├── report.json
├── AD-USR-001-InactiveUsers.csv
├── AD-PRIV-001-PrivilegedGroups-Domain_Admins.csv

📈 Scoring
Un score global est calculé avec un niveau de maturité :
A : Très bon niveau
B : Bon niveau
C : Moyen
D : Faible
E : Critique

🧪 Mode Mock
Le mode Mock permet de :
tester sans AD
développer de nouveaux checks
valider les exports
-UseMockData

➕ Ajouter un check
Créer un fichier dans src/Checks/...
Respecter le format de sortie (Finding)
L’ajouter dans AuditRunner.ps1

⚠️ Contraintes :
un check = une responsabilité
aucune dépendance directe à l’AD
utiliser uniquement les données des Collectors

📌 Checks actuellement disponibles
Voir docs/checks.md

📅 Roadmap
Activation du ConfigPath
Ajout checks Computers
Ajout checks Domain
Ajout checks Kerberos
Export HTML / Markdown
Ajout de tests automatisés

⚠️ Avertissement
Cet outil fournit un audit de premier niveau uniquement.
Il ne remplace pas un audit de sécurité complet.
