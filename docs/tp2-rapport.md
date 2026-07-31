# TP2 - Déploiement sécurisé avec Terraform, Ansible et CI/CD

**Auteur : Rémi Thuillier**

---

# Objectif

L'objectif de ce TP était de déployer une infrastructure cloud sécurisée à l'aide de Terraform, puis d'automatiser le déploiement et la configuration grâce à Ansible et à un pipeline CI/CD.

La partie Azure n'a pas été réalisée conformément aux consignes du devoir final.

---

# Partie A - Socle Terraform et Backend S3

## Initialisation Terraform

Commande exécutée :

\`\`\`bash
terraform init
\`\`\`

Résultat :

\`\`\`text
Terraform has been successfully initialized!
\`\`\`

### Capture

AJOUTER CAPTURE TERRAFORM INIT

---

## Validation de la configuration

Commande :

\`\`\`bash
terraform validate
\`\`\`

Résultat :

\`\`\`text
Success! The configuration is valid.
\`\`\`

### Capture

AJOUTER CAPTURE TERRAFORM VALIDATE

---

## Mise en place du Backend S3

Un bucket S3 dédié au stockage du state Terraform a été créé.

Mesures de sécurité appliquées :

- Versioning activé
- Chiffrement activé
- Block Public Access activé
- Verrouillage du state activé
- Backend distant configuré

Configuration utilisée :

\`\`\`hcl
backend "s3" {
  bucket       = "remi-tfstate-test-1785488912"
  key          = "terraform.tfstate"
  region       = "us-east-1"
  encrypt      = true
  use_lockfile = true
}
\`\`\`

Réinitialisation du backend :

\`\`\`bash
terraform init -reconfigure
\`\`\`

Résultat :

\`\`\`text
Successfully configured the backend "s3"!
Terraform has been successfully initialized!
\`\`\`

### Capture

AJOUTER CAPTURE BACKEND S3

---

# Partie B - Déploiement AWS

## Infrastructure déployée

L'infrastructure AWS comprend :

- Une instance EC2 Ubuntu
- Un disque GP3 chiffré
- Une adresse IP publique
- Un serveur Nginx
- Une page Web déployée automatiquement

---

## Terraform Plan

Commande :

\`\`\`bash
terraform plan
\`\`\`

Terraform affiche l'ensemble des actions avant le déploiement.

### Capture

AJOUTER CAPTURE TERRAFORM PLAN

---

## Terraform Apply

Commande :

\`\`\`bash
terraform apply
\`\`\`

Résultat :

\`\`\`text
Apply complete!
\`\`\`

### Capture

AJOUTER CAPTURE TERRAFORM APPLY

---

# Contrôles de sécurité

## IMDSv2

Le service de métadonnées EC2 est protégé par la configuration suivante :

\`\`\`hcl
metadata_options {
  http_endpoint               = "enabled"
  http_tokens                 = "required"
  http_put_response_hop_limit = 2
}
\`\`\`

Cette configuration force l'utilisation d'IMDSv2.

---

## Chiffrement du disque

Le disque principal de la machine est chiffré :

\`\`\`hcl
root_block_device {
  encrypted = true
}
\`\`\`

---

## Authentification SSH

La connexion SSH a été vérifiée avec :

\`\`\`bash
ssh -i labsuser.pem ubuntu@54.205.181.154
\`\`\`

### Capture

AJOUTER CAPTURE SSH

---

# Vérification du serveur Web

## Adresse IP publique

Commande :

\`\`\`bash
terraform output
\`\`\`

Résultat :

\`\`\`text
instance_ip = "54.205.181.154"
\`\`\`

### Capture

AJOUTER CAPTURE TERRAFORM OUTPUT

---

## Vérification du service Nginx

Commande :

\`\`\`bash
sudo systemctl status nginx
\`\`\`

Résultat :

\`\`\`text
active (running)
\`\`\`

### Capture

AJOUTER CAPTURE NGINX

---

## Vérification locale

Commande :

\`\`\`bash
curl localhost
\`\`\`

Résultat :

Affichage de la page Web hébergée localement.

### Capture

AJOUTER CAPTURE CURL LOCALHOST

---

## Vérification depuis un navigateur

Le site est accessible depuis Internet à l'adresse :

\`\`\`text
http://54.205.181.154
\`\`\`

Le site déployé est :

\`\`\`text
Subito Pizza
\`\`\`

### Capture

AJOUTER CAPTURE SITE SUBITO PIZZA

---

# Gestion du Terraform State

Le fichier Terraform State contient des informations sensibles.

Trois exemples d'informations identifiées :

1. Adresse IP publique de l'instance EC2.
2. Adresse IP privée de l'instance EC2.
3. Identifiants AWS des ressources créées.

Afin de sécuriser ce fichier, les mesures suivantes ont été appliquées :

- Backend S3 distant
- Chiffrement du bucket
- Versioning activé
- Block Public Access activé
- State Locking avec use_lockfile = true

---

# Détection de dérive (Drift)

Le TP prévoit la modification manuelle d'une ressource afin que Terraform détecte la dérive.

Dans l'environnement AWS Academy utilisé, le Security Group fourni par le laboratoire possédait déjà la règle suivante :

\`\`\`text
22/tcp -> 0.0.0.0/0
\`\`\`

Terraform permet néanmoins de comparer en permanence :

- la configuration Terraform ;
- le fichier d'état ;
- l'infrastructure réelle.

L'exécution de :

\`\`\`bash
terraform plan
\`\`\`

permet de détecter toute différence entre l'infrastructure réelle et l'état attendu.

---

# Automatisation avec Ansible

Les fichiers suivants ont été ajoutés :

\`\`\`text
ansible.cfg
inventory.ini
playbook.yml
\`\`\`

Le playbook met automatiquement en place :

- l'installation de Nginx ;
- le démarrage du service ;
- le déploiement du site Web Subito Pizza.

### Capture

AJOUTER CAPTURE PLAYBOOK ANSIBLE

---

# Pipeline CI/CD

Le projet intègre un pipeline GitHub Actions.

Déclencheur :

\`\`\`yaml
workflow_dispatch
\`\`\`

Le pipeline exécute automatiquement :

\`\`\`text
make fmt
make tflint
make trivy
terraform apply
terraform output
génération inventory.ini
ansible-playbook
\`\`\`

Le déploiement n'est exécuté que si les contrôles de qualité et de sécurité réussissent :

\`\`\`yaml
needs: validate
\`\`\`

---

## Vérification de sécurité

Exécution :

\`\`\`bash
make fmt
make tflint
make trivy
\`\`\`

Résultats :

- Terraform Format : OK
- TFLint : OK
- Trivy : 0 mauvaise configuration détectée

### Capture

AJOUTER CAPTURE MAKE FMT

### Capture

AJOUTER CAPTURE MAKE TFLINT

### Capture

AJOUTER CAPTURE MAKE TRIVY

---

# Comparatif AWS / Azure

| Concept | AWS | Azure |
|----------|----------|----------|
| Réseau virtuel | VPC | Virtual Network |
| Sous-réseau | Subnet | Subnet |
| Pare-feu | Security Group | Network Security Group |
| Machine virtuelle | EC2 | Virtual Machine |
| Adresse publique | Public IP | Public IP |
| Stockage objet | S3 | Blob Storage |
| État Terraform | Backend S3 | Storage Account |

---

# Analyse de l'incident Capital One

La configuration applique :

\`\`\`hcl
http_tokens = "required"
\`\`\`

Cette protection impose l'utilisation d'un jeton pour accéder au service de métadonnées EC2.

Dans l'incident Capital One, cela aurait fortement limité l'exploitation de la vulnérabilité SSRF utilisée contre le serveur exposé.

Cependant, IMDSv2 n'aurait pas corrigé le problème principal : les permissions IAM associées à la machine étaient trop importantes et ne respectaient pas le principe du moindre privilège.

---

# Destruction de l'infrastructure

Commande utilisée :

\`\`\`bash
terraform destroy
\`\`\`

Résultat attendu :

\`\`\`text
Destroy complete!
\`\`\`

### Capture

AJOUTER CAPTURE TERRAFORM DESTROY

### Capture

AJOUTER CAPTURE CONSOLE AWS VIDE

---

# Conclusion

Ce TP a permis de mettre en œuvre :

- Terraform
- AWS EC2
- Backend S3 sécurisé
- Chiffrement du stockage
- IMDSv2
- Gestion sécurisée du State Terraform
- Détection de dérive
- Ansible
- Déploiement automatique d'un site Web
- GitHub Actions
- CI/CD
- TFLint
- Trivy

L'ensemble de l'infrastructure peut désormais être déployé, contrôlé et configuré automatiquement tout en appliquant les bonnes pratiques de sécurité étudiées durant le module.
EOFcat > docs/tp2-rapport.md <<'EOF'
# TP2 - Déploiement sécurisé avec Terraform, Ansible et CI/CD

**Auteur : Rémi Thuillier**

---

# Objectif

L'objectif de ce TP était de déployer une infrastructure cloud sécurisée à l'aide de Terraform, puis d'automatiser le déploiement et la configuration grâce à Ansible et à un pipeline CI/CD.

La partie Azure n'a pas été réalisée conformément aux consignes du devoir final.

---

# Partie A - Socle Terraform et Backend S3

## Initialisation Terraform

Commande exécutée :

\`\`\`bash
terraform init
\`\`\`

Résultat :

\`\`\`text
Terraform has been successfully initialized!
\`\`\`

### Capture

AJOUTER CAPTURE TERRAFORM INIT

---

## Validation de la configuration

Commande :

\`\`\`bash
terraform validate
\`\`\`

Résultat :

\`\`\`text
Success! The configuration is valid.
\`\`\`

### Capture

AJOUTER CAPTURE TERRAFORM VALIDATE

---

## Mise en place du Backend S3

Un bucket S3 dédié au stockage du state Terraform a été créé.

Mesures de sécurité appliquées :

- Versioning activé
- Chiffrement activé
- Block Public Access activé
- Verrouillage du state activé
- Backend distant configuré

Configuration utilisée :

\`\`\`hcl
backend "s3" {
  bucket       = "remi-tfstate-test-1785488912"
  key          = "terraform.tfstate"
  region       = "us-east-1"
  encrypt      = true
  use_lockfile = true
}
\`\`\`

Réinitialisation du backend :

\`\`\`bash
terraform init -reconfigure
\`\`\`

Résultat :

\`\`\`text
Successfully configured the backend "s3"!
Terraform has been successfully initialized!
\`\`\`

### Capture

AJOUTER CAPTURE BACKEND S3

---

# Partie B - Déploiement AWS

## Infrastructure déployée

L'infrastructure AWS comprend :

- Une instance EC2 Ubuntu
- Un disque GP3 chiffré
- Une adresse IP publique
- Un serveur Nginx
- Une page Web déployée automatiquement

---

## Terraform Plan

Commande :

\`\`\`bash
terraform plan
\`\`\`

Terraform affiche l'ensemble des actions avant le déploiement.

### Capture

AJOUTER CAPTURE TERRAFORM PLAN

---

## Terraform Apply

Commande :

\`\`\`bash
terraform apply
\`\`\`

Résultat :

\`\`\`text
Apply complete!
\`\`\`

### Capture

AJOUTER CAPTURE TERRAFORM APPLY

---

# Contrôles de sécurité

## IMDSv2

Le service de métadonnées EC2 est protégé par la configuration suivante :

\`\`\`hcl
metadata_options {
  http_endpoint               = "enabled"
  http_tokens                 = "required"
  http_put_response_hop_limit = 2
}
\`\`\`

Cette configuration force l'utilisation d'IMDSv2.

---

## Chiffrement du disque

Le disque principal de la machine est chiffré :

\`\`\`hcl
root_block_device {
  encrypted = true
}
\`\`\`

---

## Authentification SSH

La connexion SSH a été vérifiée avec :

\`\`\`bash
ssh -i labsuser.pem ubuntu@54.205.181.154
\`\`\`

### Capture

AJOUTER CAPTURE SSH

---

# Vérification du serveur Web

## Adresse IP publique

Commande :

\`\`\`bash
terraform output
\`\`\`

Résultat :

\`\`\`text
instance_ip = "54.205.181.154"
\`\`\`

### Capture

AJOUTER CAPTURE TERRAFORM OUTPUT

---

## Vérification du service Nginx

Commande :

\`\`\`bash
sudo systemctl status nginx
\`\`\`

Résultat :

\`\`\`text
active (running)
\`\`\`

### Capture

AJOUTER CAPTURE NGINX

---

## Vérification locale

Commande :

\`\`\`bash
curl localhost
\`\`\`

Résultat :

Affichage de la page Web hébergée localement.

### Capture

AJOUTER CAPTURE CURL LOCALHOST

---

## Vérification depuis un navigateur

Le site est accessible depuis Internet à l'adresse :

\`\`\`text
http://54.205.181.154
\`\`\`

Le site déployé est :

\`\`\`text
Subito Pizza
\`\`\`

### Capture

AJOUTER CAPTURE SITE SUBITO PIZZA

---

# Gestion du Terraform State

Le fichier Terraform State contient des informations sensibles.

Trois exemples d'informations identifiées :

1. Adresse IP publique de l'instance EC2.
2. Adresse IP privée de l'instance EC2.
3. Identifiants AWS des ressources créées.

Afin de sécuriser ce fichier, les mesures suivantes ont été appliquées :

- Backend S3 distant
- Chiffrement du bucket
- Versioning activé
- Block Public Access activé
- State Locking avec use_lockfile = true

---

# Détection de dérive (Drift)

Le TP prévoit la modification manuelle d'une ressource afin que Terraform détecte la dérive.

Dans l'environnement AWS Academy utilisé, le Security Group fourni par le laboratoire possédait déjà la règle suivante :

\`\`\`text
22/tcp -> 0.0.0.0/0
\`\`\`

Terraform permet néanmoins de comparer en permanence :

- la configuration Terraform ;
- le fichier d'état ;
- l'infrastructure réelle.

L'exécution de :

\`\`\`bash
terraform plan
\`\`\`

permet de détecter toute différence entre l'infrastructure réelle et l'état attendu.

---

# Automatisation avec Ansible

Les fichiers suivants ont été ajoutés :

\`\`\`text
ansible.cfg
inventory.ini
playbook.yml
\`\`\`

Le playbook met automatiquement en place :

- l'installation de Nginx ;
- le démarrage du service ;
- le déploiement du site Web Subito Pizza.

### Capture

AJOUTER CAPTURE PLAYBOOK ANSIBLE

---

# Pipeline CI/CD

Le projet intègre un pipeline GitHub Actions.

Déclencheur :

\`\`\`yaml
workflow_dispatch
\`\`\`

Le pipeline exécute automatiquement :

\`\`\`text
make fmt
make tflint
make trivy
terraform apply
terraform output
génération inventory.ini
ansible-playbook
\`\`\`

Le déploiement n'est exécuté que si les contrôles de qualité et de sécurité réussissent :

\`\`\`yaml
needs: validate
\`\`\`

---

## Vérification de sécurité

Exécution :

\`\`\`bash
make fmt
make tflint
make trivy
\`\`\`

Résultats :

- Terraform Format : OK
- TFLint : OK
- Trivy : 0 mauvaise configuration détectée

### Capture

AJOUTER CAPTURE MAKE FMT

### Capture

AJOUTER CAPTURE MAKE TFLINT

### Capture

AJOUTER CAPTURE MAKE TRIVY

---

# Comparatif AWS / Azure

| Concept | AWS | Azure |
|----------|----------|----------|
| Réseau virtuel | VPC | Virtual Network |
| Sous-réseau | Subnet | Subnet |
| Pare-feu | Security Group | Network Security Group |
| Machine virtuelle | EC2 | Virtual Machine |
| Adresse publique | Public IP | Public IP |
| Stockage objet | S3 | Blob Storage |
| État Terraform | Backend S3 | Storage Account |

---

# Analyse de l'incident Capital One

La configuration applique :

\`\`\`hcl
http_tokens = "required"
\`\`\`

Cette protection impose l'utilisation d'un jeton pour accéder au service de métadonnées EC2.

Dans l'incident Capital One, cela aurait fortement limité l'exploitation de la vulnérabilité SSRF utilisée contre le serveur exposé.

Cependant, IMDSv2 n'aurait pas corrigé le problème principal : les permissions IAM associées à la machine étaient trop importantes et ne respectaient pas le principe du moindre privilège.

---

# Destruction de l'infrastructure

Commande utilisée :

\`\`\`bash
terraform destroy
\`\`\`

Résultat attendu :

\`\`\`text
Destroy complete!
\`\`\`

### Capture

AJOUTER CAPTURE TERRAFORM DESTROY

### Capture

AJOUTER CAPTURE CONSOLE AWS VIDE

---

# Conclusion

Ce TP a permis de mettre en œuvre :

- Terraform
- AWS EC2
- Backend S3 sécurisé
- Chiffrement du stockage
- IMDSv2
- Gestion sécurisée du State Terraform
- Détection de dérive
- Ansible
- Déploiement automatique d'un site Web
- GitHub Actions
- CI/CD
- TFLint
- Trivy

L'ensemble de l'infrastructure peut désormais être déployé, contrôlé et configuré automatiquement tout en appliquant les bonnes pratiques de sécurité étudiées durant le module.
