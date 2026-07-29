# TP1 — Rapport

## 1. Pourquoi --no-verify fonctionne-t-il, et quelle est la seule parade réellement efficace ?

Les hooks pre-commit s'exécutent côté client, sous le contrôle total du développeur qui possède
son poste. L'option --no-verify indique simplement à Git de sauter cette étape locale. Aucun
mécanisme ne peut empêcher un utilisateur de contourner un contrôle qui s'exécute sur sa propre
machine. La seule parade efficace est de déplacer le contrôle côté serveur : rejouer les mêmes
vérifications (gitleaks, lint...) dans une pipeline CI obligatoire, combinée à une protection de
branche qui bloque toute fusion si la CI échoue.

## 2. Le secret purgé était-il présent sur le serveur distant ? Que fallait-il faire en premier ?

Oui : le commit contenant config/app.env a été poussé avec --no-verify avant la purge
(git filter-repo). Il était donc bien présent sur GitHub, potentiellement déjà visible ou
indexé. S'il s'était agi d'un vrai secret, la première action à mener n'aurait pas été de
réécrire l'historique, mais de révoquer immédiatement la clé chez l'émetteur (ici, dans la
console AWS), avant toute autre étape. La réécriture d'historique ne fait que nettoyer un
dépôt, elle ne neutralise en rien un secret déjà exposé.

## 3. Mutabilité des tags et incident tj-actions/changed-files

Un tag Git est un pointeur nommé, mais rien n'empêche de le réécrire pour qu'il pointe vers un
autre commit (git tag -f puis push --force --tags), sans changer son nom. Dans l'incident
tj-actions/changed-files, l'attaquant a exploité exactement cette propriété : il a réécrit tous
les tags de version (v1 à v45) pour qu'ils pointent vers un commit malveillant, alors que les
utilisateurs de l'action référençaient ces tags en pensant obtenir toujours le même code. Seul
un épinglage par empreinte de commit complète (immuable par construction) aurait empêché
l'attaque.

## 4. Trois éléments du dépôt relevant de la gestion de configuration au sens ITIL

- Le dépôt Git lui-même, qui fait office de CMDB : il recense tous les éléments de
  configuration du projet (fichiers, structure, dépendances) et leurs relations.
- Chaque commit, qui constitue une baseline (ligne de base) datée et identifiée par une
  empreinte, servant de référence pour revenir à un état connu et sain en cas de problème.
- Le fichier .pre-commit-config.yaml (ou plus généralement les pipelines CI), qui
  formalise le processus de contrôle des changements avant leur intégration — équivalent
  moderne du processus de gestion des changements ITIL.
