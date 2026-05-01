# QuickStart — AD-Hygiene-Audit

Guide de démarrage rapide pour lancer un audit d’hygiène Active Directory avec **AD-Hygiene-Audit**.

Ce document est volontairement détaillé afin de permettre à une personne junior de lancer l’outil sans connaissance avancée de PowerShell ou d’Active Directory.

---

# 1. Objectif du QuickStart

Ce guide explique comment :

1. préparer l’environnement ;
2. lancer un premier audit en mode Mock ;
3. créer un fichier de connexion sécurisé à l’Active Directory ;
4. lancer un audit réel sur l’AD ;
5. récupérer les rapports générés.

---

# 2. Prérequis

## 2.1 PowerShell

L’outil nécessite PowerShell 7 ou supérieur.

Vérifier la version :

pwsh --version
Exemple attendu :
PowerShell 7.x.x

2.2 Module Active Directory

Pour interroger un vrai Active Directory, le module PowerShell ActiveDirectory doit être disponible.

Tester :
Get-Module -ListAvailable ActiveDirectory
Si rien ne s’affiche, le module n’est pas installé.
Sur Windows, il faut installer les outils RSAT :
Get-WindowsCapability -Name RSAT.ActiveDirectory\* -Online
Puis installer le module si nécessaire :
Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0

2.3 Droits nécessaires

Le compte utilisé pour lancer l’audit doit pouvoir lire l’annuaire Active Directory.
Il n’est pas nécessaire d’utiliser un compte administrateur du domaine.
Un compte de lecture standard suffit généralement pour :
lire les utilisateurs ;
lire les ordinateurs ;
lire les groupes ;
lire les politiques du domaine.

3. Récupérer le projet

Cloner le projet :

git clone https://github.com/<user>/AD-Hygiene-Audit.git
cd AD-Hygiene-Audit
Vérifier que le fichier principal est présent :
Get-ChildItem
Vous devez voir notamment :
Invoke-ADHygieneAudit.ps1
src/
docs/

4. Premier test en mode Mock

Le mode Mock permet de tester l’outil sans Active Directory.
Il utilise de fausses données internes.
C’est le mode recommandé pour vérifier que tout fonctionne.
Commande :
pwsh -File ./Invoke-ADHygieneAudit.ps1 `  -UseMockData`
-OutputPath ./outputs `  -InactiveDays 90`
-Mode Full
Explication :
Paramètre Rôle
-UseMockData Utilise les données de test
-OutputPath ./outputs Dossier où seront générés les rapports
-InactiveDays 90 Seuil d’inactivité en jours
-Mode Full Lance tous les checks disponibles

5. Vérifier les résultats Mock

Après exécution, vérifier le dossier :
Get-ChildItem ./outputs
Vous devez obtenir des fichiers de rapport, par exemple :
report.json
AD-USR-001-InactiveUsers.csv
AD-COMP-001-InactiveComputers.csv
AD-PRIV-001-PrivilegedGroups.csv
Si ces fichiers existent, l’outil fonctionne correctement.

6. Préparer la connexion à l’Active Directory

6.1 Pourquoi créer un fichier Credential ?

Pour éviter de mettre un mot de passe en clair dans une commande ou dans un script.
L’outil utilise un fichier sécurisé généré par PowerShell avec :
Export-Clixml
Ce fichier contient les identifiants chiffrés pour l’utilisateur Windows courant.
Important :
le fichier ne doit pas être partagé ;
il ne fonctionne que pour l’utilisateur Windows qui l’a créé ;
il ne doit pas être commité dans Git.

6.2 Créer le fichier de connexion

Depuis la racine du projet :
Get-Credential | Export-Clixml -Path ./ad-credential.xml
Une fenêtre s’ouvre.
Saisir le compte AD au format :
DOMAINE\utilisateur
ou :
utilisateur@domaine.local
Exemple :
ACME\audit.ad
ou :
audit.ad@acme.local

6.3 Vérifier que le fichier existe

Test-Path ./ad-credential.xml
Résultat attendu :
True

6.4 Tester la lecture du credential

$Credential = Import-Clixml -Path ./ad-credential.xml
$Credential.UserName
Résultat attendu :
ACME\audit.ad
ou :
audit.ad@acme.local
Ne jamais afficher le mot de passe.

7. Lancer l’audit sur le vrai Active Directory

Pour utiliser l’AD réel, il ne faut plus utiliser -UseMockData.
Commande :
pwsh -File ./Invoke-ADHygieneAudit.ps1 `  -CredentialPath ./ad-credential.xml`
-OutputPath ./outputs-ad `  -InactiveDays 90`
-Mode Full
Explication :
Paramètre Rôle
-CredentialPath ./ad-credential.xml Fichier contenant le compte AD sécurisé
-OutputPath ./outputs-ad Dossier des rapports AD réels
-InactiveDays 90 Seuil d’inactivité
-Mode Full Lance tous les checks

8. Comment être sûr qu’on n’est plus en mode Mock ?

Le mode Mock est activé uniquement si la commande contient :
-UseMockData

Donc :
pwsh -File ./Invoke-ADHygieneAudit.ps1 -UseMockData
= mode Mock

Alors que :
pwsh -File ./Invoke-ADHygieneAudit.ps1 -CredentialPath ./ad-credential.xml
= mode AD réel

9. Lire les résultats de l’audit AD

Lister les fichiers :

Get-ChildItem ./outputs-ad
Ouvrir le rapport JSON :
Get-Content ./outputs-ad/report.json
Ouvrir les fichiers CSV dans Excel ou LibreOffice.
Les CSV correspondent aux findings détectés par check.

10. Modes disponibles

Mode Description
Full Lance tous les checks
Daily Mode prévu pour exécution planifiée
UsersOnly Lance uniquement les checks utilisateurs
PrivilegedOnly Lance uniquement les checks liés aux privilèges

Exemple utilisateurs uniquement :
pwsh -File ./Invoke-ADHygieneAudit.ps1
-CredentialPath ./ad-credential.xml
-OutputPath ./outputs-users
-InactiveDays 90 `
-Mode UsersOnly

11. Erreurs fréquentes

Le module ActiveDirectory est introuvable

Erreur probable :
The specified module 'ActiveDirectory' was not loaded

Solution :
Installer RSAT Active Directory.
Le fichier credential est introuvable
Erreur probable :
CredentialPath not found

Solution :

Vérifier le chemin :
Test-Path ./ad-credential.xml
Mauvais identifiant ou mot de passe

Solution :

Regénérer le fichier :

Remove-Item ./ad-credential.xml
Get-Credential | Export-Clixml -Path ./ad-credential.xml
Aucun résultat dans certains CSV
Ce n’est pas forcément une erreur.
Cela peut signifier que le check n’a détecté aucun problème.

Exemple :
aucun compte inactif ;
aucun OS obsolète ;
aucun compte privilégié non conforme.

12. Bonnes pratiques

Ne jamais commiter les credentials
Ajouter dans .gitignore :
*.xml
*credential\*
_cred_
Utiliser un compte dédié
Créer idéalement un compte AD dédié :
audit.ad
Avec uniquement les droits nécessaires en lecture.
Séparer les sorties Mock et AD réel
Exemple :
outputs-mock/
outputs-ad/
Cela évite de mélanger les résultats de test et les résultats réels.

13. Exemple complet recommandé

Test Mock
pwsh -File ./Invoke-ADHygieneAudit.ps1 `  -UseMockData`
-OutputPath ./outputs-mock `  -InactiveDays 90`
-Mode Full
Création du credential
Get-Credential | Export-Clixml -Path ./ad-credential.xml
Audit AD réel
pwsh -File ./Invoke-ADHygieneAudit.ps1 `  -CredentialPath ./ad-credential.xml`
-OutputPath ./outputs-ad `  -InactiveDays 90`
-Mode Full

14. Rappel important

AD-Hygiene-Audit est un outil d’audit de premier niveau.
Il permet d’identifier rapidement des faiblesses d’hygiène Active Directory.
Il ne remplace pas :
un audit de sécurité complet ;
une revue d’architecture AD ;
un pentest ;
une analyse approfondie des ACL, GPO ou chemins d’attaque.
