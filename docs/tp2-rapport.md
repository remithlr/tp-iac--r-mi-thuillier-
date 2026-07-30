# TP2 - Déploiement multi-cloud sécurisé

**Auteur : Rémi Thuillier**

---

# Objectif

L'objectif de ce TP est de déployer une infrastructure cloud avec Terraform en appliquant les bonnes pratiques de sécurité.

---

# Partie A - Initialisation Terraform

## Initialisation

Commande exécutée :

\`\`\`bash
terraform init
\`\`\`

Résultat :

\`\`\`
Terraform has been successfully initialized!
\`\`\`

### Capture 1

AJOUTER ICI LA CAPTURE DU TERRAFORM INIT

---

## Validation

Commande :

\`\`\`bash
terraform validate
\`\`\`

Résultat :

\`\`\`
Success! The configuration is valid.
\`\`\`

### Capture 2

AJOUTER ICI LA CAPTURE DU TERRAFORM VALIDATE

---

# Partie B - Déploiement AWS

## Configuration

Infrastructure déployée :

- Instance EC2 Ubuntu 24.04
- Volume GP3 chiffré
- IMDSv2 activé
- Installation automatique de Nginx
- Déploiement Terraform

---

## Mesures de sécurité

### IMDSv2

\`\`\`hcl
metadata_options {
  http_endpoint = "enabled"
  http_tokens   = "required"
}
\`\`\`

### Chiffrement du disque

\`\`\`hcl
root_block_device {
  encrypted   = true
  volume_size = 10
  volume_type = "gp3"
}
\`\`\`

---

# Terraform Plan

Commande :

\`\`\`bash
terraform plan -out=dev.tfplan
\`\`\`

Résultat :

\`\`\`
Plan: 1 to add, 0 to change, 0 to destroy.
\`\`\`

### Capture 3

AJOUTER ICI LA CAPTURE DU TERRAFORM PLAN

---

# Terraform Apply

Commande :

\`\`\`bash
terraform apply dev.tfplan
\`\`\`

Résultat :

\`\`\`
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
\`\`\`

### Capture 4

AJOUTER ICI LA CAPTURE DU TERRAFORM APPLY

---

# Instance EC2

Terraform a créé avec succès une instance EC2.

Commande :

\`\`\`bash
terraform output instance_ip
\`\`\`

IP publique obtenue :

\`\`\`
34.229.147.88
\`\`\`

### Capture 5

AJOUTER ICI LA CAPTURE DU TERRAFORM OUTPUT

---

# Vérification Nginx

Commande :

\`\`\`bash
sudo systemctl status nginx
\`\`\`

Résultat :

\`\`\`
active (running)
\`\`\`

### Capture 6

AJOUTER ICI LA CAPTURE DU STATUS NGINX

---

# Vérification locale

Commande :

\`\`\`bash
curl localhost
\`\`\`

Résultat :

\`\`\`html
<h1>TP2 Rémi Thuillier</h1>
<p>Terraform fonctionne !</p>
\`\`\`

### Capture 7

AJOUTER ICI LA CAPTURE DU CURL LOCALHOST

---

# Vérification du site Web

Accès à l'adresse publique :

\`\`\`
http://34.229.147.88
\`\`\`

Le site est accessible depuis Internet.

### Capture 8

AJOUTER ICI LA CAPTURE DU SITE DANS LE NAVIGATEUR

---

# Gestion du Terraform State

Le fichier Terraform State contient plusieurs informations sensibles :

1. Adresse IP publique
2. Adresse IP privée
3. Configuration complète de l'infrastructure

Le state Terraform ne doit jamais être exposé publiquement.

Les bonnes pratiques sont :

- chiffrement
- contrôle d'accès
- versioning
- verrouillage du state

---

# Réponse à la question Capital One

IMDSv2 impose l'utilisation d'un jeton pour accéder au service de métadonnées AWS. Une attaque SSRF classique ne peut généralement pas récupérer ce jeton. Cette protection aurait réduit le risque d'exploitation du service de métadonnées. Cependant, le principe du moindre privilège IAM reste la mesure de sécurité principale.

---

# Difficultés rencontrées

Lors de ce TP, plusieurs limitations IAM AWS Academy ont été rencontrées :

- ec2:CreateVpc
- ec2:CreateSecurityGroup
- ec2:DescribeImages

La solution a consisté à réutiliser les ressources AWS existantes du laboratoire plutôt que d'en créer de nouvelles.

---

# Conclusion

Le déploiement Terraform a été réalisé avec succès.

Objectifs atteints :

- Terraform initialisé
- Terraform validé
- Terraform plan exécuté
- Terraform apply exécuté
- Instance EC2 créée
- Nginx déployé automatiquement
- IMDSv2 activé
- Disque chiffré
- Site Web accessible

Terraform permet de déployer automatiquement une infrastructure cloud de manière reproductible et sécurisée.
