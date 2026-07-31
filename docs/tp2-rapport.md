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

<img width="945" height="575" alt="image" src="https://github.com/user-attachments/assets/0e2b231b-a715-437f-9988-b23793389f02" />


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

<img width="945" height="246" alt="image" src="https://github.com/user-attachments/assets/7e65000f-5b6b-4dee-bac8-ed9f561800ab" />


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

<img width="945" height="461" alt="image" src="https://github.com/user-attachments/assets/2500b8ef-a196-41b8-a86d-b24674a5285e" />

<img width="945" height="639" alt="image" src="https://github.com/user-attachments/assets/b684da6d-7656-4aca-93d3-8b786495df5a" />


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

<img width="945" height="464" alt="image" src="https://github.com/user-attachments/assets/0f971e9e-1e2a-43e6-aff6-01d79f5dffee" />


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

<img width="945" height="788" alt="image" src="https://github.com/user-attachments/assets/c3520391-abef-4aec-a610-316557376cbf" />

<img width="945" height="171" alt="image" src="https://github.com/user-attachments/assets/e8e7e668-9b3c-4dd0-bb4b-9c7dcf1fecfe" />



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

<img width="945" height="841" alt="image" src="https://github.com/user-attachments/assets/3f0d6cc7-bb01-4807-aea2-615651492b8e" />


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

<img width="945" height="171" alt="image" src="https://github.com/user-attachments/assets/3ee79ec8-4fda-47cf-9fa5-5dae44e8a280" />


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

<img width="945" height="480" alt="image" src="https://github.com/user-attachments/assets/ba89bf60-f6ef-48b4-8313-00d1321f5cff" />


---

## Vérification locale

Commande :

\`\`\`bash
curl localhost
\`\`\`

Résultat :

Affichage de la page Web hébergée localement.

<img width="838" height="752" alt="image" src="https://github.com/user-attachments/assets/8e958046-c04d-4c20-814c-38640d7cb78f" />


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

<img width="945" height="473" alt="image" src="https://github.com/user-attachments/assets/7e95c2f9-812c-42ba-b713-1fc9c982bcf8" />


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

<img width="945" height="138" alt="image" src="https://github.com/user-attachments/assets/f11c040c-87e0-4341-a2fd-42120cce33be" />

<img width="945" height="804" alt="image" src="https://github.com/user-attachments/assets/607cb694-55e2-42b8-bf08-7e3e992460a8" />

<img width="945" height="405" alt="image" src="https://github.com/user-attachments/assets/5906cca2-e1dc-4256-93c8-62d4643ebb86" />




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

<img width="945" height="126" alt="image" src="https://github.com/user-attachments/assets/c5ece92a-57ce-4216-829a-6bfdf58cbe59" />

<img width="945" height="108" alt="image" src="https://github.com/user-attachments/assets/51c40d83-3e8a-4c12-9433-4818253bd0c2" />

<img width="945" height="622" alt="image" src="https://github.com/user-attachments/assets/5a839ff9-f6df-4b92-bce5-03e1044d94a5" />


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

<img width="945" height="334" alt="image" src="https://github.com/user-attachments/assets/650ec952-16e0-44b4-91e6-5950fb74405e" />

<img width="945" height="410" alt="image" src="https://github.com/user-attachments/assets/7bb54bcb-79dc-4fbf-a139-b62156f6f557" />

<img width="945" height="379" alt="image" src="https://github.com/user-attachments/assets/6d662533-1037-4b74-b8dd-61dbeeb1b88d" />


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

