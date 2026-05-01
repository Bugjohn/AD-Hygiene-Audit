# AD-Hygiene-Audit

Outil PowerShell d’audit d’hygiène Active Directory (niveau 1 sécurité), conçu avec une architecture modulaire, robuste et exploitable en entreprise.

---

## 🎯 Objectif

Identifier rapidement les faiblesses classiques d’un Active Directory :

- comptes inactifs
- mots de passe non conformes
- exposition des comptes privilégiés
- configuration domaine à risque

L’outil est conçu pour être :

- ✅ simple à exécuter
- ✅ lisible dans ses résultats
- ✅ modulaire (ajout de checks facile)
- ✅ compatible environnement de test (mode Mock)

---

⚡ Quick Start (5 minutes)

1️⃣ Cloner le projet

git clone https://github.com/<user>/AD-Hygiene-Audit.git
cd AD-Hygiene-Audit

2️⃣ Tester immédiatement (mode Mock)

👉 Aucun prérequis AD nécessaire
pwsh -File ./Invoke-ADHygieneAudit.ps1 `  -UseMockData`
-OutputPath ./outputs `  -InactiveDays 90`
-Mode Full
✔️ Résultat : un audit complet simulé est généré dans outputs/

3️⃣ Lire les résultats

outputs/
├── report.json
├── AD-USR-001-InactiveUsers.csv
├── AD-PRIV-001-PrivilegedGroups.csv

🔐 Connexion à un Active Directory (mode réel)
Prérequis
PowerShell 7+
RSAT / Module ActiveDirectory installé
Accès réseau à l’AD

1️⃣ Créer un fichier de credentials sécurisé

Get-Credential | Export-Clixml -Path ./cred.xml
👉 Cela stocke ton compte AD de manière chiffrée

2️⃣ Lancer l’audit en mode réel

pwsh -File ./Invoke-ADHygieneAudit.ps1 `  -CredentialPath ./cred.xml`
-OutputPath ./outputs `  -InactiveDays 90`
-Mode Full

🔁 Désactiver le mode Mock

👉 NE PAS utiliser :
-UseMockData
👉 Le mode AD réel est automatiquement utilisé si :
-UseMockData est absent
-CredentialPath est fourni

## 🚀 QuickStart détaillé

Un guide pas-à-pas est disponible ici :

[docs/QuickStart.md](docs/QuickStart.md)

🏗️ Architecture

Le projet est structuré en modules :
Collectors
Source unique de données (AD ou Mock)
Checks
Règles d’audit indépendantes
Core
Orchestration (AuditRunner, ScoringEngine)
Reports
Export JSON + CSV

⚠️ Règles fondamentales
✔️ Les Collectors sont la seule source de données
❌ Les Checks ne doivent jamais interroger l’AD
✔️ Le mode Mock doit toujours fonctionner

▶️ Modes d’exécution

Mode Description
Full Tous les checks
Daily Identique à Full (planification)
UsersOnly Utilisateurs uniquement
PrivilegedOnly Comptes à privilèges

📊 Résultats

JSON
vue globale
scoring
synthèse
CSV
un fichier par check
exploitable Excel / SIEM

📈 Scoring

Score Niveau
A Très bon
B Bon
C Moyen
D Faible
E Critique

🧪 Mode Mock (important)

Le mode Mock permet de :
tester sans AD
développer de nouveaux checks
valider les exports
Activation :
-UseMockData

➕ Ajouter un check

Étapes
Créer un fichier dans :
src/Checks/<Category>/
Respecter le format de sortie (Finding)
Ajouter le check dans :
AuditRunner.ps1

⚠️ Contraintes

un check = une responsabilité
aucun appel direct à l’AD
utiliser uniquement les données Collectors

📌 Checks disponibles

Voir :
docs/checks.md

📅 Roadmap

Activation du ConfigPath
Ajout checks avancés (AD Tiering, ACL, GPO)
Export HTML / Markdown
Ajout tests automatisés
Intégration CI/CD

⚠️ Avertissement

Cet outil fournit un audit de premier niveau.

👉 Il ne remplace pas :
un audit de sécurité complet
une revue d’architecture AD
un audit Red Team / Pentest

🤝 Contribution
Les contributions sont les bienvenues :
nouveaux checks
amélioration des exports
optimisation des performances

📬 Support
Projet interne / expérimental.
Adapter selon votre contexte entreprise.
