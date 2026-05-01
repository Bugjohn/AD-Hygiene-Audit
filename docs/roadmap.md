# Roadmap

Cette roadmap reflète l'état du projet après stabilisation du mode Mock.

## État actuel

- Mock complet pour le MVP : ✔
- Checks Users, Computers, Domain et Privileged branchés dans le runner : ✔
- Exports JSON et CSV disponibles : ✔
- Scoring numérique robuste basé sur `Severity` et `Count` : ✔
- `ConfigPath` disponible : ✔
- Runner partiellement piloté par la configuration : ✔
- Mode Active Directory réel préparé dans les collectors : en attente de validation
- Exports HTML et Markdown : futur

## Court terme

- Valider le mode Active Directory réel sur un environnement de test contrôlé.
- Uniformiser la structure des findings, notamment `Status`, `Recommendation` et `Data`.
- Compléter le pilotage par configuration pour tous les checks et exports.
- Ajouter des tests automatisés sur les modes `Full`, `Daily`, `UsersOnly` et `PrivilegedOnly`.
- Stabiliser les jeux de données Mock comme références de non-régression.

## Moyen terme

- Étendre la couverture AD réelle au-delà du scénario nominal.
- Ajouter des checks avancés uniquement après branchement runner + Mock + tests.
- Documenter les limites opérationnelles du mode AD réel.
- Ajouter une validation de configuration plus stricte.

## Futur

- Export HTML.
- Export Markdown.
- Intégration CI/CD.
- Packaging de release.

## Hors MVP actuel

- Audit complet des ACL.
- Analyse exhaustive GPO.
- AD Tiering complet.
- Analyse de chemins d'attaque.
- Remplacement d'un audit sécurité, Red Team ou Pentest.
