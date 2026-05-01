# Checks disponibles

Ce document décrit les règles d’audit actuellement implémentées dans AD-Hygiene-Audit.

---

## 🎯 Objectif des checks

Les checks permettent d’identifier des faiblesses de sécurité dans Active Directory selon des règles simples et indépendantes.

Chaque check :

- a une responsabilité unique
- utilise uniquement les données fournies par les Collectors
- retourne un ou plusieurs Findings

---

## 🔐 Utilisateurs

### AD-USR-001 — Comptes inactifs

**Description :**
Identifie les comptes utilisateurs non utilisés depuis un certain nombre de jours.

**Paramètre :**

- `InactiveDays`

**Risque :**

- Comptes dormants exploitables par un attaquant
- Accès non surveillés
- Augmentation de la surface d’attaque

---

### AD-USR-002 — Password Never Expires

**Description :**
Détecte les comptes dont le mot de passe n’expire jamais.

**Risque :**

- Compromission persistante
- Absence de rotation des mots de passe
- Non-conformité aux bonnes pratiques

---

### AD-USR-003 — Comptes administrateurs

**Description :**
Identifie les comptes utilisateurs appartenant aux groupes administrateurs principaux.

Groupes analysés :

- Domain Admins
- Enterprise Admins
- Administrators

**Risque :**

- Comptes utilisateurs avec privilèges élevés
- Surface d’attaque administrative
- Mauvaise séparation entre comptes standards et comptes d’administration

**Sortie :**
Un finding agrégé contenant la liste des comptes administrateurs détectés.

---

## 👑 Groupes privilégiés

### AD-PRIV-001 — Membres des groupes privilégiés

**Description :**
Liste les membres des groupes sensibles :

- Domain Admins
- Enterprise Admins
- Administrators

**Objectif :**

- Identifier les comptes à privilèges élevés
- Réduire le périmètre d’administration
- Améliorer la gouvernance des accès

---

### AD-PRIV-002 — Comptes inactifs dans groupes admin

**Description :**
Identifie les comptes inactifs présents dans des groupes privilégiés.

**Paramètre :**

- `InactiveDays`

**Risque :**

- Comptes fantômes avec privilèges élevés
- Escalade de privilèges facilitée
- Mauvaise hygiène des accès sensibles

---

### AD-COMP-001 — Ordinateurs inactifs

**Description :**
Identifie les comptes ordinateurs dont la dernière connexion dépasse le seuil d’inactivité défini.

**Paramètre :**

- `InactiveDays`

**Risque :**

- Postes obsolètes encore présents dans l’annuaire
- Surface d’attaque inutile
- Inventaire AD non maîtrisé

---

### AD-DOM-001 — Password Policy du domaine

**Description :**
Lit la stratégie de mot de passe du domaine Active Directory.

**Données collectées :**

- Longueur minimale du mot de passe
- Complexité activée ou non
- Durée maximale du mot de passe
- Durée minimale du mot de passe
- Seuil de verrouillage
- Durée de verrouillage

**Risque :**

- Politique de mot de passe trop faible
- Absence de complexité
- Durée excessive des mots de passe

---

## 📌 Convention de nommage

Format :
AD-<CAT>-XXX

| Catégorie | Description         |
| --------- | ------------------- |
| USR       | Utilisateurs        |
| PRIV      | Groupes privilégiés |
| COMP      | Ordinateurs         |
| DOM       | Domaine             |
| KRB       | Kerberos            |

---

## 🧱 Structure d’un check

Un check doit :

- recevoir ses données en entrée (Users, Groups, etc.)
- ne jamais interroger directement Active Directory
- être indépendant des autres checks
- retourner un ou plusieurs Findings

---

## 📊 Structure d’un Finding

Un Finding contient typiquement :

- `Id`
- `Title`
- `Category`
- `Severity`
- `Description`
- `Data`

---

## 🚧 Checks à venir

### Utilisateurs

- AD-USR-003 : Comptes administrateurs

### Ordinateurs

- AD-COMP-002 : OS obsolètes

### Domaine

- AD-DOM-001 : Password Policy
- AD-DOM-002 : Lockout Policy

### Kerberos

- AD-KRB-001 : Comptes avec SPN
- AD-KRB-002 : Unconstrained Delegation
