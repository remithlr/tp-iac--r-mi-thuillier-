# Mini-Writeup — Commandes du TP1

## Partie A — Initialisation

git clone <url>
→ Récupère une copie locale du dépôt distant vide créé sur GitHub.

git add <fichiers> / git commit -m "..."
→ Ajoute les fichiers à l'index puis crée un commit. Trois commits séparés
  ont été faits pour respecter Conventional Commits et garder un historique
  lisible (un commit = un changement cohérent).

git push -u origin main
→ Envoie les commits locaux vers le dépôt distant, en liant la branche
  locale main à origin/main pour les prochains push/pull.

## Partie B — Garde-fous

pre-commit install
→ Installe le hook Git local (.git/hooks/pre-commit) qui exécutera
  automatiquement les vérifications définies dans .pre-commit-config.yaml
  avant chaque commit.

pre-commit run --all-files
→ Lance tous les hooks configurés sur l'ensemble des fichiers du dépôt,
  pas seulement ceux modifiés. Utile pour la première vérification globale.

## Partie C — Provoquer la fuite

git commit -m "chore: config"
→ Tentative de commit d'un fichier contenant un faux secret AWS.
  Le hook gitleaks bloque le commit (exit code 1) car le secret est détecté.

git commit -m "chore: config" --no-verify
→ Contourne volontairement tous les hooks pre-commit. Démontre que ce
  contrôle est uniquement local et non contraignant.

make secrets (→ gitleaks detect --source . --verbose)
→ Scanne tout l'historique du dépôt (pas seulement l'état courant) et
  retrouve le secret même après son commit, avec le SHA exact du commit
  concerné.

git filter-repo --path config/app.env --invert-paths --force
→ Réécrit l'intégralité de l'historique Git pour supprimer toute trace
  du fichier config/app.env, y compris dans les commits passés.
  Change les empreintes de tous les commits qui suivent.

git log --all --full-history -- config/app.env
→ Vérifie qu'aucune trace du fichier ne subsiste dans l'historique
  (commande sans sortie = fichier introuvable).

git push origin main --force
→ Repousse l'historique réécrit sur le dépôt distant. Obligatoire après
  filter-repo puisque les empreintes de commit ont changé.

## Partie D — Signature et protection

git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
→ Configure Git pour signer automatiquement chaque commit avec la clé
  SSH locale, au lieu d'une clé GPG classique.

git log --show-signature -1
→ Vérifie localement la signature du dernier commit. Nécessite un fichier
  allowed_signers associant l'email du commit à la clé publique.

git push origin main (après activation de la protection de branche)
→ Refusé par GitHub (GH006: Protected branch update failed), car la
  règle de protection sur main exige de passer par une pull request.

git checkout -b docs/rapport-tp1
git push -u origin docs/rapport-tp1
→ Crée une branche dédiée pour le rapport, seule façon de contribuer à
  main une fois la protection de branche active.
